-- Created by Redgate Data Modeler (https://datamodeler.redgate-platform.com)
-- Last modification date: 2026-01-08 02:41:47.072

-- tables
-- Table: ingredients
CREATE TABLE ingredients (
    id int  NOT NULL,
    name varchar(50)  NOT NULL,
    category varchar(50)  NOT NULL,
    icon_path varchar(100)  NULL,
    CONSTRAINT ingredients_pk PRIMARY KEY (id)
);

-- Table: pantry
CREATE TABLE pantry (
    is_available boolean  NOT NULL,
    users_id int  NOT NULL,
    ingridients_id int  NOT NULL,
    CONSTRAINT pantry_pk PRIMARY KEY (users_id,ingridients_id)
);

-- Table: recipe_ingredients
CREATE TABLE recipe_ingredients (
    quantity_text varchar(50)  NOT NULL,
    raw_text varchar(50)  NOT NULL,
    ingridients_id int  NOT NULL,
    recipes_id int  NOT NULL,
    CONSTRAINT recipe_ingredients_pk PRIMARY KEY (ingridients_id,recipes_id)
);

-- Table: recipe_steps
CREATE TABLE recipe_steps (
    id int  NOT NULL,
    step_order int  NOT NULL,
    instruction text  NOT NULL,
    timer_seconds int  NOT NULL,
    recipes_id int  NOT NULL,
    CONSTRAINT recipe_steps_pk PRIMARY KEY (id)
);

-- Table: recipes
CREATE TABLE recipes (
    id int  NOT NULL,
    title varchar(100)  NOT NULL,
    description text  NOT NULL,
    servings int  NOT NULL,
    prep_time int  NOT NULL,
    source_type varchar(50)  NOT NULL,
    is_draft boolean  NOT NULL,
    updated_at timestamp  NOT NULL,
    deleted_at timestamp  NOT NULL,
    users_id int  NOT NULL,
    CONSTRAINT recipes_pk PRIMARY KEY (id)
);

-- Table: users
CREATE TABLE users (
    id int  NOT NULL,
    email varchar(200)  NOT NULL,
    password varchar(255)  NOT NULL,
    CONSTRAINT users_pk PRIMARY KEY (id)
);

-- foreign keys
-- Reference: pantry_ingridients (table: pantry)
ALTER TABLE pantry ADD CONSTRAINT pantry_ingridients
    FOREIGN KEY (ingridients_id)
    REFERENCES ingredients (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: pantry_users (table: pantry)
ALTER TABLE pantry ADD CONSTRAINT pantry_users
    FOREIGN KEY (users_id)
    REFERENCES users (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: recipe_ingridients_ingridients (table: recipe_ingredients)
ALTER TABLE recipe_ingredients ADD CONSTRAINT recipe_ingridients_ingridients
    FOREIGN KEY (ingridients_id)
    REFERENCES ingredients (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: recipe_ingridients_recipes (table: recipe_ingredients)
ALTER TABLE recipe_ingredients ADD CONSTRAINT recipe_ingridients_recipes
    FOREIGN KEY (recipes_id)
    REFERENCES recipes (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: recipe_steps_recipes (table: recipe_steps)
ALTER TABLE recipe_steps ADD CONSTRAINT recipe_steps_recipes
    FOREIGN KEY (recipes_id)
    REFERENCES recipes (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: recipes_users (table: recipes)
ALTER TABLE recipes ADD CONSTRAINT recipes_users
    FOREIGN KEY (users_id)
    REFERENCES users (id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- End of file.

