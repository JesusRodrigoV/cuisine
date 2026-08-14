-- =============================================
-- ESQUEMA BASE DE DATOS: APP COCINA (FINAL)
-- =============================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ENUMS
CREATE TYPE recipe_source_type AS ENUM ('MANUAL', 'SCAN_OCR', 'WEB_IMPORT');
CREATE TYPE log_level_type AS ENUM ('INFO', 'WARNING', 'ERROR', 'SECURITY');

-- ---------------------------------------------
-- 1. TABLAS PRINCIPALES
-- ---------------------------------------------

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(200) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE NULL 
);

CREATE TABLE ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50) NOT NULL,
    icon_path VARCHAR(200) NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP 
);

-- ---------------------------------------------
-- 2. RECETAS
-- ---------------------------------------------

CREATE TABLE recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT NULL,
    servings INT NOT NULL DEFAULT 1,
    prep_time_minutes INT NOT NULL DEFAULT 0,
    source_type recipe_source_type NOT NULL DEFAULT 'MANUAL',
    is_draft BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE NULL,

    CONSTRAINT fk_recipes_user FOREIGN KEY (user_id) 
        REFERENCES users (id) ON DELETE RESTRICT
);

CREATE TABLE recipe_steps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL,
    step_order INT NOT NULL,
    instruction TEXT NOT NULL,
    timer_seconds INT NULL,
    
    CONSTRAINT fk_steps_recipe FOREIGN KEY (recipe_id) 
        REFERENCES recipes (id) ON DELETE CASCADE
);

-- ---------------------------------------------
-- 3. TABLAS PIVOTE
-- ---------------------------------------------

CREATE TABLE recipe_ingredients (
    recipe_id UUID NOT NULL,
    ingredient_id UUID NOT NULL,
    quantity_text VARCHAR(100) NOT NULL,
    raw_text VARCHAR(100) NULL,
    
    PRIMARY KEY (recipe_id, ingredient_id),

    CONSTRAINT fk_ri_recipe FOREIGN KEY (recipe_id) 
        REFERENCES recipes (id) ON DELETE CASCADE,
    
    CONSTRAINT fk_ri_ingredient FOREIGN KEY (ingredient_id) 
        REFERENCES ingredients (id) ON DELETE RESTRICT
);

CREATE TABLE pantry (
    user_id UUID NOT NULL,
    ingredient_id UUID NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (user_id, ingredient_id),
    
    CONSTRAINT fk_pantry_user FOREIGN KEY (user_id) 
        REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_pantry_ingredient FOREIGN KEY (ingredient_id) 
        REFERENCES ingredients (id) ON DELETE RESTRICT
);

-- ---------------------------------------------
-- 4. SISTEMA DE LOGS Y SEGURIDAD
-- ---------------------------------------------

CREATE TABLE system_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NULL, 
    action VARCHAR(100) NOT NULL, 
    details TEXT NULL, 
    ip_address VARCHAR(45) NULL, 
    severity log_level_type NOT NULL DEFAULT 'INFO',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) 
        REFERENCES users (id) ON DELETE SET NULL 
);

CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_revoked BOOLEAN DEFAULT FALSE,
    
    CONSTRAINT fk_token_user FOREIGN KEY (user_id) 
        REFERENCES users (id) ON DELETE CASCADE
);

-- =============================================
-- 5. AUTOMATIZACIÓN Y SEGURIDAD (TRIGGERS)
-- =============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION prevent_hard_delete()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'ALERTA DE SEGURIDAD: No está permitido borrar registros físicamente en esta tabla. Usa Soft Delete (actualiza el campo deleted_at).';
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';


-- =============================================
-- APLICACIÓN DE TRIGGERS POR TABLA
-- =============================================

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
    
CREATE TRIGGER trg_users_no_delete
    BEFORE DELETE ON users
    FOR EACH ROW
    EXECUTE FUNCTION prevent_hard_delete();


CREATE TRIGGER trg_recipes_updated_at
    BEFORE UPDATE ON recipes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_recipes_no_delete
    BEFORE DELETE ON recipes
    FOR EACH ROW
    EXECUTE FUNCTION prevent_hard_delete();
    

CREATE TRIGGER trg_pantry_updated_at
    BEFORE UPDATE ON pantry
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
    

CREATE TRIGGER trg_ingredients_updated_at
    BEFORE UPDATE ON ingredients
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();