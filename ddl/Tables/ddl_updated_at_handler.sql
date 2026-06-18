CREATE OR REPLACE FUNCTION virginia_dev_saayam_rdbms.updated_at_handler()
RETURNS TRIGGER AS $$
BEGIN
    -- If last_updated_at wasn't explicitly changed by the API, force UTC now.
    IF (NEW.last_updated_at IS NOT DISTINCT FROM OLD.last_updated_at) THEN
        NEW.last_updated_at = (now() AT TIME ZONE 'UTC');
    END IF;

    -- existing: volunteer_applications
    IF (TG_TABLE_NAME = 'volunteer_applications') THEN
        IF (NEW.govt_id_path IS DISTINCT FROM OLD.govt_id_path) THEN
            NEW.path_updated_at = (now() AT TIME ZONE 'UTC');
        END IF;
        IF (NEW.terms_and_conditions IS TRUE
            AND (OLD.terms_and_conditions IS FALSE OR OLD.terms_and_conditions IS NULL)) THEN
            NEW.terms_accepted_at = (now() AT TIME ZONE 'UTC');
        END IF;

    -- existing: volunteer_details
    ELSIF (TG_TABLE_NAME = 'volunteer_details') THEN
        IF (NEW.govt_id_path1 IS DISTINCT FROM OLD.govt_id_path1) THEN
            NEW.path1_updated_at = (now() AT TIME ZONE 'UTC');
        END IF;
        IF (NEW.govt_id_path2 IS DISTINCT FROM OLD.govt_id_path2) THEN
            NEW.path2_updated_at = (now() AT TIME ZONE 'UTC');
        END IF;
        IF (NEW.terms_and_conditions IS TRUE
            AND (OLD.terms_and_conditions IS FALSE OR OLD.terms_and_conditions IS NULL)) THEN
            NEW.terms_accepted_at = (now() AT TIME ZONE 'UTC');
        END IF;

    -- NEW: internal_applications
    ELSIF (TG_TABLE_NAME = 'internal_applications') THEN
        IF (NEW.government_id_s3_key IS DISTINCT FROM OLD.government_id_s3_key) THEN
            NEW.govt_id_path_updated_at = (now() AT TIME ZONE 'UTC');
        END IF;
        IF (NEW.acknowledgments IS DISTINCT FROM OLD.acknowledgments) THEN
            NEW.acknowledgments_accepted_at = (now() AT TIME ZONE 'UTC');
        END IF;
        IF (NEW.application_status IS DISTINCT FROM OLD.application_status
            AND NEW.application_status IN ('APPROVED', 'REJECTED')) THEN
            NEW.reviewed_at = (now() AT TIME ZONE 'UTC');
        END IF;

    -- NEW: internal_team
    ELSIF (TG_TABLE_NAME = 'internal_team') THEN
        IF (NEW.is_active IS FALSE
            AND (OLD.is_active IS TRUE OR OLD.is_active IS NULL)) THEN
            NEW.deactivated_at = (now() AT TIME ZONE 'UTC');
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
