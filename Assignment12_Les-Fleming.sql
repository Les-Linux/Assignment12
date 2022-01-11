# TABLE CREATION

CREATE TABLE IF NOT EXISTS `customer` (
  `customer_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `number` varchar(45) NOT NULL,
  PRIMARY KEY (`customer_id`),
  CONSTRAINT uc_name_number UNIQUE (`name`,`number`)
);

/* -------------------------------------------------------------------- */

CREATE TABLE `pizza` (
  `pizza_id` int(11) NOT NULL AUTO_INCREMENT,
  `pizza` varchar(45) NOT NULL,
  `price` decimal(4,2) NOT NULL,
  PRIMARY KEY (`pizza_id`)
) ;

/* -------------------------------------------------------------------- */

CREATE TABLE `order` (
  `order_id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `pizza_id` int(11) NOT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_id`),
  FOREIGN KEY (`customer_id`) REFERENCES customer(`customer_id`),
  FOREIGN KEY (`pizza_id`) REFERENCES pizza (`pizza_id`)
) ;



/* -------------------------------------------------------------------- */

# JOIN TABLE (many-to-many relationship)

CREATE TABLE `customer_order` (
  `customer_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
  FOREIGN KEY (`order_id`) REFERENCES `order` (`order_id`)
);


/* -------------------------------------------------------------------- */
# insert data into tables
/*
	ignore is required for mysql/mariadb instances with strict mode set (default) to ignore truncate message on date conversion
*/

# Populate Customer Table
INSERT INTO `customer`(name,number) VALUES ('Trevor Page', '226-555-4982');
INSERT INTO `customer` (name,number) VALUES ('John Doe', '555-555-9498');

#Populate Pizza Table
INSERT INTO `pizza`(pizza,price) VALUES('Pepperoni & Cheese',7.99);
INSERT INTO `pizza` (pizza,price) VALUES('Vegetarian',9.99);
INSERT INTO `pizza` (pizza,price) VALUES('Meat Lovers', 14.99);
INSERT INTO `pizza`(pizza,price)  VALUES('Hawaiian', 12.99);

# ORDER 1
INSERT IGNORE INTO `order`(`customer_id`,`pizza_id`,`date`)  VALUES(1,1,str_to_date('9/10/2014 9:47:00 AM','%c/%e/%Y %T'));
INSERT INTO customer_order SELECT 1, MAX(order_id) FROM `order`;
INSERT ignore INTO `order` (`customer_id`,`pizza_id`,`date`) VALUES(1,3,str_to_date('9/10/2014 9:47:00 AM','%c/%e/%Y %T'));
INSERT INTO customer_order SELECT 1,MAX(order_id) FROM `order`;

# ORDER 2
INSERT IGNORE INTO `order` (customer_id,pizza_id,`date`) VALUES(2,2,str_to_date('9/10/2014 13:20:00 AM','%c/%e/%Y %T'));
INSERT INTO customer_order SELECT 2, MAX(order_id) FROM `order`;
INSERT IGNORE INTO `order` (customer_id,pizza_id,`date`) VALUES(2,3,str_to_date('9/10/2014 13:20:00 AM','%c/%e/%Y %T'));
INSERT INTO customer_order SELECT 2, MAX(order_id) FROM `order`;
INSERT IGNORE INTO `order` (customer_id,pizza_id,`date`) VALUES(2,3,str_to_date('9/10/2014 13:20:00 AM','%c/%e/%Y %T'));
INSERT INTO customer_order SELECT 2, MAX(order_id) FROM `order`;


# ORDER 3
INSERT IGNORE INTO `order` (customer_id,pizza_id,`date`) VALUES(1,3,str_to_date('9/10/2014 9:47:00 AM','%c/%e/%Y %T'));
INSERT INTO customer_order SELECT 1, MAX(order_id) FROM `order`;
INSERT IGNORE INTO `order` (customer_id,pizza_id,`date`) VALUES(1,4,str_to_date('9/10/2014 9:47:00 AM','%c/%e/%Y %T'));
INSERT INTO customer_order SELECT 1, MAX(order_id) FROM `order`;



/* -------------------------------------------------------------------- */
# a view to get all orders

USE `coderscampus`;
CREATE  OR REPLACE VIEW `uv_order` AS
    SELECT 
		cust.name,
        cust.number AS 'Phone Number',
        DATE_FORMAT(ord.`date`,'%m/%d/%Y %h:%i %p') AS 'Order date/time',
        piz.pizza
        
    FROM
        `customer_order` cust_order
	INNER JOIN `customer` cust ON cust_order.customer_id = cust.customer_id
    INNER JOIN `order` ord ON cust_order.order_id = ord.order_id
    INNER JOIN `pizza` piz ON ord.pizza_id = piz.pizza_id;


/* -------------------------------------------------------------------- */
# a view to sum the spending for each customer

DROP VIEW IF EXISTS `coderscampus`.`uv_Spend`;
USE `coderscampus`;
CREATE 
     OR REPLACE ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `coderscampus`.`uv_spend` AS
    SELECT 
		cust.name,
        sum(piz.price) AS price
    FROM
        `customer_order` cust_order
	INNER JOIN `customer` cust ON cust_order.customer_id = cust.customer_id
    INNER JOIN `order` ord ON cust_order.order_id = ord.order_id
    INNER JOIN `pizza` piz ON ord.pizza_id = piz.pizza_id
    GROUP BY(cust.name);


/* -------------------------------------------------------------------- */
# a view to sum the spending for each customer by date


USE `coderscampus`;
CREATE  OR REPLACE VIEW `uv_order_by_date` AS
    SELECT 
        cust.name,
        DATE_FORMAT(`ord`.`date`, '%m/%d/%Y %h:%i %p') AS `Order date/time`,
        count(*) AS orders
    FROM
        `customer_order` cust_order
	INNER JOIN `customer` cust ON cust_order.customer_id = cust.customer_id
    INNER JOIN `order` ord ON cust_order.order_id = ord.order_id
    INNER JOIN `pizza` piz ON ord.pizza_id = piz.pizza_id
	GROUP BY (ord.`date`);
