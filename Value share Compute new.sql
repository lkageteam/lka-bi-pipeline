drop table if exists value_share_compute_modified;
CREATE TABLE value_share_compute_modified AS
SELECT
    tr.posID AS partner,
    tr.userInfo__id,
    COALESCE(tn.LOCALITE, 'unknown') AS LOCALITE,
    COALESCE(tn.ville, 'unknown')    AS VILLE,

    WEEK(tr.date, 0)  AS Week,
    MONTH(tr.date)    AS Month,
    YEAR(tr.date)     AS Year,

    -- Sunday of that week
    DATE_SUB(MIN(tr.date), INTERVAL DAYOFWEEK(MIN(tr.date)) - 1 DAY) AS DateValue,

    -- Outlier-filtered averages (± 2 std dev, computed per week)
    AVG(CASE WHEN ABS(tr.cashinMTN      - sub.avg_cashinMTN)      <= 2 * sub.std_cashinMTN      THEN tr.cashinMTN      END) AS cashinMTN,
    AVG(CASE WHEN ABS(tr.cashoutMTN     - sub.avg_cashoutMTN)     <= 2 * sub.std_cashoutMTN     THEN tr.cashoutMTN     END) AS cashoutMTN,
    AVG(CASE WHEN ABS(tr.cashinMOOV     - sub.avg_cashinMOOV)     <= 2 * sub.std_cashinMOOV     THEN tr.cashinMOOV     END) AS cashinMoov,
    AVG(CASE WHEN ABS(tr.cashoutMoov    - sub.avg_cashoutMoov)    <= 2 * sub.std_cashoutMoov    THEN tr.cashoutMoov    END) AS cashoutMoov,
    AVG(CASE WHEN ABS(tr.cashinceltiis  - sub.avg_cashinceltiis)  <= 2 * sub.std_cashinceltiis  THEN tr.cashinceltiis  END) AS cashinCeltiis,
    AVG(CASE WHEN ABS(tr.cashoutceltiis - sub.avg_cashoutceltiis) <= 2 * sub.std_cashoutceltiis THEN tr.cashoutceltiis END) AS cashoutCeltiis,
    AVG(CASE WHEN ABS(tr.AirtimeMTN     - sub.avg_AirtimeMTN)     <= 2 * sub.std_AirtimeMTN     THEN tr.AirtimeMTN     END) AS AirtimeMTN,
    AVG(CASE WHEN ABS(tr.airtimeMoov    - sub.avg_airtimeMoov)    <= 2 * sub.std_airtimeMoov    THEN tr.airtimeMoov    END) AS AirtimeMoov,
    AVG(CASE WHEN ABS(tr.airtimeCeltiis - sub.avg_airtimeCeltiis) <= 2 * sub.std_airtimeCeltiis THEN tr.airtimeCeltiis END) AS AirtimeCeltiis,

    -- Volumes (cashin + cashout per operator, both outlier-filtered)
    AVG(CASE WHEN ABS(tr.cashinMTN      - sub.avg_cashinMTN)      <= 2 * sub.std_cashinMTN      THEN tr.cashinMTN      END) +
    AVG(CASE WHEN ABS(tr.cashoutMTN     - sub.avg_cashoutMTN)     <= 2 * sub.std_cashoutMTN     THEN tr.cashoutMTN     END) AS VolumeMTN,

    AVG(CASE WHEN ABS(tr.cashinMOOV     - sub.avg_cashinMOOV)     <= 2 * sub.std_cashinMOOV     THEN tr.cashinMOOV     END) +
    AVG(CASE WHEN ABS(tr.cashoutMoov    - sub.avg_cashoutMoov)    <= 2 * sub.std_cashoutMoov    THEN tr.cashoutMoov    END) AS VolumeMoov,

    AVG(CASE WHEN ABS(tr.cashinceltiis  - sub.avg_cashinceltiis)  <= 2 * sub.std_cashinceltiis  THEN tr.cashinceltiis  END) +
    AVG(CASE WHEN ABS(tr.cashoutceltiis - sub.avg_cashoutceltiis) <= 2 * sub.std_cashoutceltiis THEN tr.cashoutceltiis END) AS VolumeCeltiis

FROM tsa_reports tr

-- ✅ Location enrichment first
LEFT JOIN tsa_numenclature tn
    ON tr.userInfo__id = tn.TSA_ID

-- ✅ Per-week outlier thresholds — each week gets its own mean and std dev
JOIN (
    SELECT
        YEAR(date)              AS ref_year,
        WEEK(date, 0)           AS ref_week,
        AVG(cashinMTN)          AS avg_cashinMTN,       STDDEV(cashinMTN)          AS std_cashinMTN,
        AVG(cashoutMTN)         AS avg_cashoutMTN,      STDDEV(cashoutMTN)         AS std_cashoutMTN,
        AVG(cashinMOOV)         AS avg_cashinMOOV,      STDDEV(cashinMOOV)         AS std_cashinMOOV,
        AVG(cashoutMoov)        AS avg_cashoutMoov,     STDDEV(cashoutMoov)        AS std_cashoutMoov,
        AVG(cashinceltiis)      AS avg_cashinceltiis,   STDDEV(cashinceltiis)      AS std_cashinceltiis,
        AVG(cashoutceltiis)     AS avg_cashoutceltiis,  STDDEV(cashoutceltiis)     AS std_cashoutceltiis,
        AVG(AirtimeMTN)         AS avg_AirtimeMTN,      STDDEV(AirtimeMTN)         AS std_AirtimeMTN,
        AVG(airtimeMoov)        AS avg_airtimeMoov,     STDDEV(airtimeMoov)        AS std_airtimeMoov,
        AVG(airtimeCeltiis)     AS avg_airtimeCeltiis,  STDDEV(airtimeCeltiis)     AS std_airtimeCeltiis
    FROM tsa_reports
    WHERE date BETWEEN '2026-01-01' AND '2026-05-04'  -- ✅ Date range
    GROUP BY
        YEAR(date),
        WEEK(date, 0)
) sub
    ON  YEAR(tr.date)    = sub.ref_year
    AND WEEK(tr.date, 0) = sub.ref_week

-- ✅ Same date range on the main table
WHERE tr.date BETWEEN '2026-01-01' AND '2026-05-04'

GROUP BY
    tr.posID,
    tr.userInfo__id,
    tn.LOCALITE,
    tn.ville,
    YEAR(tr.date),
    WEEK(tr.date, 0),
    MONTH(tr.date)

ORDER BY
    Year,
    Week,
    tr.posID;