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
    email varchar(255) not null,
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
    foreign key (client_id) references client(id),
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
    restaurant_id int not null auto_increment,
    email varchar(255) not null,
    password varchar(255) not null,
    primary key (restaurant_id)
);

-- restaurant_session
create table restaurant_session (
    restaurant_id int not null,
    token varchar(255) not null,
    foreign key (restaurant_id) references restaurant(restaurant_id)
);

-- menu_item
        -- description: (string),
        -- id: (number),
        -- image_url: (string),
        -- name: (string),
        -- price: (number)
create table menu_item (
    id int not null auto_increment,
    name varchar(255) not null,
    description varchar(255) not null,
    price decimal(10,2) not null,
    image_url varchar(255) not null,
    primary key (id)

    

-- order
create table order (
    id int not null auto_increment,
    restaurant_id int not null,
    client_id int not null,
    is_confirmed boolean not null default false,
    is_complete boolean not null default false,
    foreign key (restaurant_id) references restaurant(id),
    foreign key (client_id) references client(id),
    primary key (id)
)

-- order_menu_item
create table order_menu_item (
    id int not null auto_increment,
    order_id int not null,
    menu_item_id int not null,
    quantity int not null default 1,
    foreign key (order_id) references order(id),
    foreign key (menu_item_id) references menu_item(id),
    primary key (id)
);