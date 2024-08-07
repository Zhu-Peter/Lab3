-- You must implement the following tables:

-- client
-- {
--     created_at: (string),
--     email: (string),
--     first_name: (string),
--     last_name: (string),
--     id: (number),
--     image_url: (string),
--     username: (string)
-- }
create table client (
    created_at datetime not null default current_timestamp,
    email varchar(255) not null unique,
    first_name varchar(255) not null,
    last_name varchar(255) not null,
    id int not null auto_increment,
    image_url varchar(255) not null,
    username varchar(255) not null,
    password varchar(255) not null,
    primary key (id)
);

-- client_session
create table client_session (
    client_id int not null,
    token varchar(255) not null,
    foreign key (client_id) references client(id) on delete cascade
);

-- restaurant
--      email: (string),
--     name: (string),
--     address: (string),
--     phone_number: (string in the form of ###-###-####),
--     bio: (string),
--     city: (string, one of Calgary, Vancouver or Toronto),
--     profile_url: (string),
--     banner_url: (string),
--     restaurant_id: (number)
create table restaurant (
    name varchar(255) not null,
    address varchar(255) not null,
    phone_number varchar(255) not null,
    bio varchar(255) not null,
    city varchar(255) not null,
    profile_url varchar(255) not null,
    banner_url varchar(255) not null,
    id int not null auto_increment,
    email varchar(255) not null unique,
    password varchar(255) not null,
    primary key (id)
);

-- restaurant_session
create table restaurant_session (
    restaurant_id int not null,
    token varchar(255) not null,
    foreign key (restaurant_id) references restaurant(id) on delete cascade
);

-- menu_item
        -- description: (string),
        -- id: (number),
        -- image_url: (string),
        -- name: (string),
        -- price: (number)
create table menu_item (
    id int not null auto_increment,
    restaurant_id int not null,
    name varchar(255) not null,
    description varchar(255) not null,
    price decimal(10,2) not null,
    image_url varchar(255) not null,
    primary key (id),
    foreign key (restaurant_id) references restaurant(id) on delete cascade

);

-- order
create table `order` (
    id int not null auto_increment,
    restaurant_id int not null,
    client_id int not null,
    is_confirmed boolean not null default false,
    is_complete boolean not null default false,
    foreign key (restaurant_id) references restaurant(id) on delete cascade,
    foreign key (client_id) references client(id) on delete cascade,
    primary key (id)
);

-- order_menu_item
create table order_menu_item (
    id int not null auto_increment,
    order_id int not null,
    menu_item_id int not null,
    quantity int not null default 1,
    foreign key (order_id) references `order`(id) on delete cascade,
    foreign key (menu_item_id) references menu_item(id) on delete cascade,
    primary key (id)
);

DELIMITER $$
$$
CREATE DEFINER=`root`@`localhost` PROCEDURE lab3.set_token(input_id int, input_token varchar(255))
begin
	insert into lab3.client_session (client_id, token) values (input_id, input_token);
	commit;
    select * from client_session where token = input_token;
END$$
DELIMITER ;


DELIMITER $$
$$
CREATE DEFINER=`root`@`localhost` PROCEDURE lab3.set_token_restaurant(input_id int, input_token varchar(255))
begin
	insert into lab3.restaurant_session (restaurant_id, token) values (input_id, input_token);
	commit;
    select * from restaurant_session where token = input_token;
END$$
DELIMITER ;


-- CLIENT
-- GET
create procedure get_client(client_id int)
    select * from client where id = client_id;

-- POST
DELIMITER $$
$$
create DEFINER=`root`@`localhost` procedure `create_client`(
    email_input varchar(255),
    first_name_input varchar(255),
    last_name_input varchar(255),
    image_url_input varchar(255),
    username_input varchar(255),
    password_input varchar(255)
)
begin
    insert into client (email, first_name, last_name, image_url, username, password) values
        (email_input, first_name_input, last_name_input, image_url_input, username_input, password_input);
    commit;
    select id from client where id = last_insert_id();
end$$
DELIMITER ;

-- PATCH
DELIMITER $$
$$
create DEFINER=`root`@`localhost` procedure `update_client`(
    email_input varchar(255),
    first_name_input varchar(255),
    last_name_input varchar(255),
    image_url_input varchar(255),
    username_input varchar(255),
    password_input varchar(255),
    token_input varchar(255)
)
begin
    DECLARE token_id int;
    select client_id into token_id from client_session where token = token_input;

    IF token_id IS NULL THEN

        ROLLBACK;

        SELECT 'Invalid token' AS message;

    ELSE
        IF email_input IS NOT NULL THEN
            update client set email = email_input where id = token_id;
        END IF;
        IF first_name_input IS NOT NULL THEN
            update client set first_name = first_name_input where id = token_id;
        END IF;
        IF last_name_input IS NOT NULL THEN
            update client set last_name = last_name_input where id = token_id;
        END IF;
        IF username_input IS NOT NULL THEN
            update client set username = username_input where id = token_id;
        END IF;
        IF password_input IS NOT NULL THEN
            update client set password = password_input where id = token_id;
        END IF;
        IF image_url_input IS NOT NULL THEN
            update client set image_url = image_url_input where id = token_id;
        END IF;

        COMMIT;
        select 'Success' AS message;
        
    END IF;
end$$
DELIMITER ;

-- DELETE
DELIMITER $$
$$
create DEFINER=`root`@`localhost` procedure `delete_client`(password_input varchar(255), token_input varchar(255))
begin
    DECLARE token_id int;
    DECLARE check_pwd varchar(255);
    select client_id into token_id from client_session where token = token_input;

    IF token_id IS NULL THEN

        ROLLBACK;

        SELECT 'Invalid token' AS message;

    ELSE
        SELECT password INTO check_pwd FROM client WHERE id = token_id;

        IF check_pwd!= password_input THEN
            ROLLBACK;
            SELECT 'Invalid password' AS message;
        ELSE
            DELETE FROM client WHERE id = token_id;
            COMMIT;
            SELECT 'Success' AS message;
        END IF;
    END IF;
end$$
DELIMITER ;

-- LOGIN
create procedure client_login(username_input varchar(255), password_input varchar(255))
    select id from client where username = username_input and password = password_input;

-- LOGOUT
DELIMITER $$
$$
create DEFINER=`root`@`localhost` procedure ` client_logout`(token_input varchar(255))
begin
    delete from client_session where token = token_input;
    commit;
    SELECT 'Success' AS message;
end$$
DELIMITER ;

-- RESTAURANT
-- GET
create procedure get_restaurant(restaurant_id int)
    select * from restaurant where id = restaurant_id;

-- POST
DELIMITER $$
$$
create DEFINER=`root`@`localhost` procedure `create_restaurant`(
    name_input varchar(255),
    address_input varchar(255),
    phone_input varchar(255),
    email_input varchar(255),
    bio_input varchar(255),
    city_input varchar(255),
    profile_url_input varchar(255),
    banner_url_input varchar(255),
    password_input varchar(255)
)
begin
    insert into restaurant (name, address, phone_number, email, bio, city, profile_url, banner_url, password) values
        (name_input, address_input, phone_input, email_input, bio_input, city_input, profile_url_input, banner_url_input, password_input);
    commit;
    select id from restaurant where id = last_insert_id();
end$$
DELIMITER ;

-- PATCH
DELIMITER $$
$$
create DEFINER=`root`@`localhost` procedure `update_restaurant`(
    name_input varchar(255),
    address_input varchar(255),
    phone_input varchar(255),
    email_input varchar(255),
    bio_input varchar(255),
    city_input varchar(255),
    profile_url_input varchar(255),
    banner_url_input varchar(255),
    password_input varchar(255),
    token_input varchar(255)
)
begin
    DECLARE token_id int;
    select restaurant_id into token_id from restaurant_session where token = token_input;

    IF token_id IS NULL THEN

        ROLLBACK;

        SELECT 'Invalid token' AS message;

    ELSE
        IF email_input IS NOT NULL THEN
            update restaurant set email = email_input where id = token_id;
        END IF;
        IF password_input IS NOT NULL THEN
            update restaurant set password = password_input where id = token_id;
        END IF;
        IF name_input IS NOT NULL THEN
            update restaurant set name = name_input where id = token_id;
        END IF;
        IF address_input IS NOT NULL THEN
            update restaurant set address = address_input where id = token_id;
        END IF;
        IF phone_input IS NOT NULL THEN
            update restaurant set phone_number = phone_input where id = token_id;
        END IF;
        IF profile_url_input IS NOT NULL THEN
            update restaurant set profile_url = profile_url_input where id = token_id;
        END IF;
        IF bio_input IS NOT NULL THEN
            update restaurant set bio = bio_input where id = token_id;
        END IF;
        IF banner_url_input IS NOT NULL THEN
            update restaurant set banner_url = banner_url_input where id = token_id;
        END IF;
        IF city_input IS NOT NULL THEN
            update restaurant set city = city_input where id = token_id;
        END IF;

        commit;
        SELECT 'Success' AS message;
    END IF;
end$$
DELIMITER ;

-- DELETE
DELIMITER $$
$$
create DEFINER=`root`@`localhost` procedure `delete_restaurant`(password_input varchar(255), token_input varchar(255))
begin
    DECLARE token_id int;
    DECLARE check_pwd varchar(255);
    select restaurant_id into token_id from restaurant_session where token = token_input;

    IF token_id IS NULL THEN

        ROLLBACK;

        SELECT 'Invalid token' AS message;

    ELSE
        SELECT password INTO check_pwd FROM client WHERE id = token_id;

        IF check_pwd!= password_input THEN
            ROLLBACK;
            SELECT 'Invalid password' AS message;
        ELSE
            DELETE FROM restaurant WHERE id = token_id;
            COMMIT;
            SELECT 'Success' AS message;
        END IF;
    END IF;
end$$
DELIMITER ;

-- LOG IN
create procedure restaurant_login(email_input varchar(255), password_input varchar(255))
    select id from restaurant where email = email_input and password = password_input;

-- LOGOUT
DELIMITER $$
$$
create DEFINER=`root`@`localhost` procedure `restaurant_logout`(token_input varchar(255))
begin
    delete from restaurant_session where token = token_input;
    commit;
    select 'Success' AS message;
end$$
DELIMITER ;

-- GET ALL RESTAURANTS
create procedure get_restaurants()
    select * from restaurant;

-- MENU
-- GET
create procedure get_menu_item(restaurant int)
    select * from menu_item where restaurant_id = restaurant;

-- POST
DELIMITER $$
$$
create DEFINER=`root`@`localhost` procedure `new_menu_item`(
    description_input varchar(255),
    image_url_input varchar(255),
    name_input varchar(255),
    price_input decimal(10,2),
    token_input varchar(255)
)
begin
    DECLARE token_id int;   
    select restaurant_id into token_id from restaurant_session where token = token_input;

    IF token_id IS NULL THEN

        ROLLBACK;

        SELECT 'Invalid token' AS message;

    ELSE
        INSERT INTO menu_item (description, image_url, name, price, restaurant_id)
        VALUES (description_input, image_url_input, name_input, price_input, token_id);

        commit;
        SELECT 'Success' AS message;

    END IF;
end$$
DELIMITER ;

-- PATCH
DELIMITER $$
$$
create DEFINER=`root`@`localhost` procedure `edit_menu_item`(
    description_input varchar(255),
    image_url_input varchar(255),
    name_input varchar(255),
    price_input decimal(10,2),
    token_input varchar(255),
    menu_id_input int
)
begin
    DECLARE token_id int;   
    select restaurant_id into token_id from restaurant_session where token = token_input;

    IF token_id IS NULL THEN

        ROLLBACK;

        SELECT 'Invalid token' AS message;

    ELSE
        IF description_input IS NOT NULL THEN
            update menu_item set description = description_input where restaurant_id = token_id and id = menu_id_input;
        END IF;
        IF image_url_input IS NOT NULL THEN
            update menu_item set image_url = image_url_input where restaurant_id = token_id and id = menu_id_input;
        END IF;
        IF name_input IS NOT NULL THEN
            update menu_item set name = name_input where restaurant_id = token_id and id = menu_id_input;
        END IF;
        IF price_input IS NOT NULL THEN
            update menu_item set price = price_input where restaurant_id = token_id and id = menu_id_input;
        END IF;

        COMMIT;
        SELECT 'Success' AS message;

    END IF;
end$$
DELIMITER ;

-- DELETE
DELIMITER $$
$$
create DEFINER=`root`@`localhost` procedure `delete_menu_item`(
    token_input varchar(255),
    menu_id_input int
)
begin
    DECLARE token_id int;   
    select restaurant_id into token_id from restaurant_session where token = token_input;

    IF token_id IS NULL THEN

        ROLLBACK;

        SELECT 'Invalid token' AS message;

    ELSE
        delete from menu_item where id = menu_id_input and restaurant_id = token_id;
        commit;
        SELECT 'Success' AS message;
    end if;
end$$
DELIMITER ;


-- ORDERS
-- GET
DELIMITER $$
$$
create DEFINER=`root`@`localhost` procedure `get_client_orders`(token_input varchar(255), is_confirmed int, is_complete int)
begin
    DECLARE token_id int;
    select client_id into token_id from client_session where token = token_input;

    IF token_id IS NULL THEN

        ROLLBACK;

        SELECT 'Invalid token' AS message;

    ELSE
    -- is_confirmed, is_complete = 1 means confirmed and complete orders
        -- is_confirmed, is_complete = 0 means not confirmed or not complete orders
        -- is_confirmed, is_complete = -1 means no filter

        IF is_complete = -1 then 
            if is_confirmed = -1 THEN
                SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE client_id = token_id;
            else
                if is_confirmed = 1 THEN
                    SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE client_id = token_id AND is_confirmed = 1;
                else
                    SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE client_id = token_id AND is_confirmed = 0;
                END IF;
            END IF;
        else
            if is_complete = 0 THEN
                if is_confirmed = -1 THEN
                    SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE client_id = token_id AND is_complete = 0;
                else
                    if is_confirmed = 1 THEN
                        SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE client_id = token_id AND is_complete = 0 AND is_confirmed = 1;
                    else
                        SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE client_id = token_id AND is_complete = 0 AND is_confirmed = 0;
                    END IF;
                END IF;
            else
                if is_complete = 1 THEN
                    if is_confirmed = -1 THEN
                        SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE client_id = token_id AND is_complete = 1;
                    else
                        if is_confirmed = 1 THEN
                            SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE client_id = token_id AND is_complete = 1 AND is_confirmed = 1;
                        else
                            SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE client_id = token_id AND is_complete = 1 AND is_confirmed = 0;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
       
    END IF;
    
end$$
DELIMITER ;

-- POST
DELIMITER $$
$$
create DEFINER=`root`@`localhost` procedure `new_client_order`(token_input varchar(255), restaurant_id_input int)
begin
    DECLARE token_id int;
    select client_id into token_id from client_session where token = token_input;

    IF token_id IS NULL THEN

        ROLLBACK;

        SELECT 'Invalid token' AS message;

    ELSE
        insert into `order` (client_id, restaurant_id) values (token_id, restaurant_id_input);
        commit;
        select id from `order` where id = LAST_INSERT_ID();
    END IF;
    
end$$
DELIMITER ;

DELIMITER $$
$$
create DEFINER=`root`@`localhost` procedure `new_order_item`(order_id_input int, item_id_input int, quantity_input int)
begin
    insert into order_menu_item (order_id, item_id) values (order_id_input, item_id_input);
    commit;
    SELECT 'Success' AS message;
end$$
DELIMITER ;

-- RESTAURANT ORDERS
-- GET
DELIMITER $$
$$
create DEFINER=`root`@`localhost` procedure `get_restaurant_orders`(token_input varchar(255), is_confirmed int, is_complete int)
begin
    DECLARE token_id int;
    select restaurant_id into token_id from restaurant_session where token = token_input;

    IF token_id IS NULL THEN

        ROLLBACK;

        SELECT 'Invalid token' AS message;

    ELSE

        IF is_complete = -1 then 
            if is_confirmed = -1 THEN
                SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE restaurant_id = token_id;
            else
                if is_confirmed = 1 THEN
                    SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE restaurant_id = token_id AND is_confirmed = 1;
                else
                    SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE restaurant_id = token_id AND is_confirmed = 0;
                END IF;
            END IF;
        else
            if is_complete = 0 THEN
                if is_confirmed = -1 THEN
                    SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE restaurant_id = token_id AND is_complete = 0;
                else
                    if is_confirmed = 1 THEN
                        SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE restaurant_id = token_id AND is_complete = 0 AND is_confirmed = 1;
                    else
                        SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE restaurant_id = token_id AND is_complete = 0 AND is_confirmed = 0;
                    END IF;
                END IF;
            else
                if is_complete = 1 THEN
                    if is_confirmed = -1 THEN
                        SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE restaurant_id = token_id AND is_complete = 1;
                    else
                        if is_confirmed = 1 THEN
                            SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE restaurant_id = token_id AND is_complete = 1 AND is_confirmed = 1;
                        else
                            SELECT * FROM `order` JOIN order_menu_item ON order.id = order_menu_item.order_id WHERE restaurant_id = token_id AND is_complete = 1 AND is_confirmed = 0;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
end$$
DELIMITER ;

-- PATCH
DELIMITER $$
$$
create DEFINER=`root`@`localhost` procedure `patch_restaurant_orders`(token_input varchar(255), order_id_input int, is_confirmed int, is_complete int)
begin
    DECLARE token_id int;
    select restaurant_id into token_id from restaurant_session where token = token_input;

    IF token_id IS NULL THEN

        ROLLBACK;

        SELECT 'Invalid token' AS message;

    ELSE
        if is_complete = 0 THEN
                UPDATE `order` SET is_complete = FALSE WHERE id = order_id_input;
                commit;
            else
                if is_complete = 1 THEN
                    UPDATE `order` SET is_complete = TRUE WHERE id = order_id_input;
                    commit;
                END IF;
            END IF;
        if is_confirmed = 0 THEN
            UPDATE `order` SET is_confirmed = FALSE WHERE id = order_id_input;
            commit;
        else
            if is_confirmed = 1 THEN
                UPDATE `order` SET is_confirmed = TRUE WHERE id = order_id_input;
                commit;
            END IF;
        END IF;
    end if;

end$$
DELIMITER ;