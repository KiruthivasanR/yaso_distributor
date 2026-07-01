class Collections {
  static const bool isDev = false; // true = testing, false = production
static String distributors =
    isDev ? "distributors_dev" : "distributors";
    static String distributorProducts =
    isDev ? "distributor_products_dev" : "distributor_products";

static String distributorOrders =
    isDev ? "distributor_orders_dev" : "distributor_orders";
  static String products = isDev ? "products_dev" : "products";
  static String orders = isDev ? "orders_dev" : "orders";
  static String users = isDev ? "users_dev" : "users";
  static String customers = isDev ? "customers_dev" : "customers";
  static String shops = isDev ? "shops_dev" : "shops";
  static String distributorCustomers =
    isDev ? "dist_customers_dev" : "dist_customers";
}