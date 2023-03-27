import dotenv from "dotenv";
import express from "express";
import cors from "cors";

const app = express();

dotenv.config();
app.use(cors());
app.use(express.json());

app.get("/get-all", (req, res = express.response) => {
  return res.status(200).json({ idOrder: 1 });
});

app.get("/get-order-by-id/:orderId", (req, res = express.response) => {
  const { orderId } = req.params;
  return res.status(200).json({ idOrder: orderId });
});

app.post("/register-order", (req, res = express.response) => {
  return res.status(200).json();
});

export default app;
