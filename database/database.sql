SET client_min_messages TO WARNING;

-- DROP and Create Schema
DROP SCHEMA IF EXISTS lbaw23113 CASCADE;
CREATE SCHEMA lbaw23113;
SET SEARCH_PATH TO lbaw23113;

--Create Types
CREATE TYPE User_Type AS ENUM ('user','admin');

-- Create Tables --
CREATE TABLE users(
    id SERIAL PRIMARY KEY,
    username TEXT,  
    email TEXT NOT NULL CONSTRAINT user_email_uk UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    password TEXT NOT NULL,
    img TEXT,
    deleted BOOLEAN DEFAULT false NOT NULL,
    rate FLOAT CONSTRAINT user_rate_ck CHECK (rate >= 0 AND rate <= 5),
    type User_Type NOT NULL DEFAULT 'user'
);

CREATE TABLE category(
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL
);

CREATE TABLE auction(
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    name TEXT NOT NULL,
    image TEXT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT true,
    start_t TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    end_t TIMESTAMP WITH TIME ZONE NOT NULL,
    CONSTRAINT auction_date_ck CHECK (end_t > start_t)
);

CREATE TABLE bid(
    id SERIAL PRIMARY KEY,
    amount FLOAT NOT NULL,
    date TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    top_bid BOOLEAN DEFAULT true NOT NULL,
    user_id INTEGER NOT NULL REFERENCES users(id) ON UPDATE CASCADE,
    auction_id INTEGER NOT NULL REFERENCES auction(id) ON UPDATE CASCADE
);

CREATE TABLE comment(
    id SERIAL PRIMARY KEY,
    message TEXT NOT NULL,
    date TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    source_user_id INTEGER NOT NULL REFERENCES users(id) ON UPDATE CASCADE
);

CREATE TABLE comment_user(
    comment_id INTEGER PRIMARY KEY REFERENCES comment(id) ON UPDATE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON UPDATE CASCADE,
    rating FLOAT CONSTRAINT check_rating_comment CHECK (rating >= 0 AND rating <= 5)
);

CREATE TABLE comment_auction(
    comment_id INTEGER PRIMARY KEY REFERENCES comment(id) ON UPDATE CASCADE,
    auction_id INTEGER NOT NULL REFERENCES auction(id) ON UPDATE CASCADE
);

CREATE TABLE notifications(
    id SERIAL PRIMARY KEY,
    message TEXT NOT NULL,
    date  TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
    user_id INTEGER REFERENCES users(id) ON UPDATE CASCADE
);

CREATE TABLE notification_bid(
    notification_id INTEGER PRIMARY KEY REFERENCES notifications(id) ON UPDATE CASCADE,
    bid_id INTEGER NOT NULL REFERENCES bid(id) ON UPDATE CASCADE
);

CREATE TABLE notification_auction(
    notification_id INTEGER PRIMARY KEY REFERENCES notifications(id) ON UPDATE CASCADE,
    auction_id INTEGER NOT NULL REFERENCES auction(id) ON UPDATE CASCADE
);

CREATE TABLE notification_comment(
    notification_id INTEGER PRIMARY KEY REFERENCES notifications(id) ON UPDATE CASCADE,
    comment_id INTEGER NOT NULL REFERENCES comment(id) ON UPDATE CASCADE
);

CREATE TABLE auction_ownership(
    user_id INTEGER REFERENCES users(id) ON UPDATE CASCADE,
    auction_id INTEGER REFERENCES auction(id) ON UPDATE CASCADE,
    PRIMARY KEY(user_id, auction_id)
);

CREATE TABLE auction_save(
    user_id INTEGER REFERENCES users(id) ON UPDATE CASCADE,
    auction_id INTEGER REFERENCES auction(id) ON UPDATE CASCADE, 
    PRIMARY KEY(user_id, auction_id)
);

CREATE TABLE auction_category(
    category_id INTEGER REFERENCES category(id) ON UPDATE CASCADE, 
    auction_id INTEGER REFERENCES auction(id) ON UPDATE CASCADE,  
    PRIMARY KEY(category_id, auction_id)
);



-- Performance indexes

CREATE INDEX idx_ownership ON auction_ownership USING btree(user_id);
CLUSTER auction_ownership USING idx_ownership;

CREATE INDEX idx_notification ON notifications USING hash(user_id);

CREATE INDEX idx_comment ON comment USING hash(source_user_id);

CREATE INDEX idx_bid_auction_user ON bid USING hash(auction_id);

--CREATE INDEX idx_bid_user_id ON bid (user_id);  Não sei se vai ficar



Alter Table auction
ADD COLUMN tsvectors TSVECTOR;

-- Function to get the description of the categories associated to an auction_id

CREATE FUNCTION get_categories_from_auction(a_id INT) RETURNS TEXT AS $$
BEGIN
RETURN (SELECT category.description
    FROM category, auction_category, auction
    WHERE auction.id = auction_category.auction_id AND auction_category.category_id = category.id AND auction.id = a_id);
END;
$$ LANGUAGE plpgsql;


-- Function to change the tsvectors of the table auction on INSERT AND UPDATE

CREATE FUNCTION func_auction_search_update() RETURNS TRIGGER AS $$
BEGIN
IF TG_OP = 'INSERT' THEN 
	NEW.tsvectors = (
		setweight(to_tsvector('english', NEW.name), 'A') ||
		setweight(to_tsvector('english', NEW.description), 'C') || 
		setweight(to_tsvector('english', get_categories_from_auction(NEW.id)), 'B')
	);
	END IF;
IF TG_OP = 'UPDATE' THEN
	IF (NEW.name <> OLD.name OR NEW.description <> OLD.description OR get_categories_from_auction(NEW.id) <> get_categories_from_auction(OLD.id) ) THEN
		NEW.tsvectors= (
		setweight(to_tsvector('english', NEW.name), 'A') ||
		setweight(to_tsvector('english', NEW.description), 'C') || 
		setweight(to_tsvector('english', get_categories_from_auction(NEW.id)), 'B')
	);
	END IF;
END IF;
RETURN NEW;
END $$
LANGUAGE plpgsql;


-- Create a trigger before insert or update on auction to change the tsvectors column.
CREATE TRIGGER trig_auction_search_update
BEFORE INSERT OR UPDATE ON auction
FOR EACH ROW
EXECUTE PROCEDURE func_auction_search_update();
 
 -- CREATE SEARCH INDEX FOR Table Auction
CREATE INDEX idx_auction_search ON auction USING GIST (tsvectors);


	
	
	
	
