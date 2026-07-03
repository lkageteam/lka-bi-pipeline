"""
Client Google Drive minimal pour recuperer les fichiers Excel de reference
(tables qui ne viennent pas de MongoDB - numenclatures, cibles, listes
statiques mises a jour manuellement par l'equipe).

Auth via compte de service (GDRIVE_SERVICE_ACCOUNT_JSON), pas de facturation
GCP requise pour l'API Drive.
"""
import io
import json
import logging
import os
from typing import Dict, List, Optional

from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload

logger = logging.getLogger(__name__)

SCOPES = ["https://www.googleapis.com/auth/drive.readonly"]


class DriveClient:
    def __init__(self, service_account_json: Optional[str] = None, folder_id: Optional[str] = None):
        raw = service_account_json or os.getenv("GDRIVE_SERVICE_ACCOUNT_JSON")
        if not raw:
            raise ValueError("GDRIVE_SERVICE_ACCOUNT_JSON environment variable is not set")
        info = json.loads(raw)
        credentials = service_account.Credentials.from_service_account_info(info, scopes=SCOPES)
        self.service = build("drive", "v3", credentials=credentials)
        self.folder_id = folder_id or os.getenv("GDRIVE_FOLDER_ID")
        if not self.folder_id:
            raise ValueError("GDRIVE_FOLDER_ID environment variable is not set")

    def check_folder_access(self) -> Dict:
        """
        Verifie explicitement que le compte de service VOIT le dossier
        lui-meme (pas seulement son contenu). Un files().list() avec un
        filtre 'in parents' renvoie silencieusement une liste vide si le
        compte n'a AUCUN acces au dossier - impossible de distinguer
        "dossier vide" de "dossier invisible" sans cet appel separe.
        """
        try:
            meta = self.service.files().get(
                fileId=self.folder_id, fields="id, name, mimeType, owners"
            ).execute()
            return {"visible": True, "meta": meta}
        except Exception as e:
            return {"visible": False, "error": str(e)}

    def list_files(self) -> List[Dict]:
        """Liste tous les fichiers du dossier surveille (non recursif)."""
        files = []
        page_token = None
        while True:
            response = self.service.files().list(
                q=f"'{self.folder_id}' in parents and trashed = false",
                fields="nextPageToken, files(id, name, mimeType, modifiedTime)",
                pageToken=page_token,
            ).execute()
            files.extend(response.get("files", []))
            page_token = response.get("nextPageToken")
            if not page_token:
                break
        return files

    def download_file(self, file_id: str, mime_type: str, dest_path: str) -> str:
        """
        Telecharge un fichier. Convertit automatiquement les Google Sheets
        natifs en xlsx (l'API Drive ne permet pas de telecharger un Google
        Sheet directement, il faut l'exporter).
        """
        os.makedirs(os.path.dirname(dest_path) or ".", exist_ok=True)

        if mime_type == "application/vnd.google-apps.spreadsheet":
            request = self.service.files().export_media(
                fileId=file_id,
                mimeType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            )
        else:
            request = self.service.files().get_media(fileId=file_id)

        with io.FileIO(dest_path, "wb") as fh:
            downloader = MediaIoBaseDownload(fh, request)
            done = False
            while not done:
                _, done = downloader.next_chunk()

        return dest_path

    def find_by_name(self, name_contains: str) -> Optional[Dict]:
        """
        Retourne le fichier le plus recemment modifie dont le nom contient
        `name_contains` (insensible a la casse), ou None si aucun match.
        """
        matches = [f for f in self.list_files() if name_contains.lower() in f["name"].lower()]
        if not matches:
            return None
        return max(matches, key=lambda f: f["modifiedTime"])
