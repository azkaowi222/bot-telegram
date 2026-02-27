import express from "express";
import {
  getAllProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
  cekStock,
  sendBroadcast,
} from "../controller/productController.js";
import {
  createUser,
  getAllUsers,
  getUserById,
} from "../controller/userController.js";

import {
  createOrder,
  getAllOrders,
  getOrderById,
  getOrderHistory,
} from "../controller/orderController.js";
import {
  getAllAccounts,
  addAccount,
  updateAccount,
  deleteAccount,
} from "../controller/accountController.js";

const router = express.Router();

//user controller
router.get("/users", getAllUsers);
router.get("/user/:id", getUserById);
router.post("/register", createUser);

//product controller
router.get("/products", getAllProducts);
router.get("/product/:id", getProductById);
router.get("/stock/:id", cekStock);
router.post("/product", createProduct);
router.patch("/product/:id", updateProduct);
router.delete("/product", deleteProduct);

//order controller
router.get("/orders", getAllOrders);
router.get("/order/:id", getOrderById);
router.post("/order", createOrder);
router.get("/order/history/:telegramId", getOrderHistory);

//account controller
router.get("/accounts", getAllAccounts);
router.post("/account/add", addAccount);
router.patch("/account/edit/:id", updateAccount);
router.delete("/account/:id", deleteAccount);

//broadcast
router.post("/broadcast", sendBroadcast);

export default router;
