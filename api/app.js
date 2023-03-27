import dotenv from "dotenv";
import express from "express";
import cors from "cors";

const app = express();

dotenv.config();
app.use(cors());
app.use(express.json());

app.get("/get-all", (req, res = express.response) => {
  return res.status(200).json([
    {
      idOrder: 1,
      date: "2021-01-01",
      dniPatient: "31464386",
      namePatient: "Christian Perez",
      sexPatient: "M",
      codAna: "1050",
      matProfessional: "123",
      prescriptionDate: "2021-01-01",
      prescriptionDescription: "Classic exam",
      totalPrice: "1000",
    },
  ]);
});

app.get("/get-order/:orderId", (req, res = express.response) => {
  const { orderId } = req.params;
  return res.status(200).json({
    idOrder: orderId,
    date: "2021-01-01",
    dniPatient: "31464386",
    namePatient: "Christian Perez",
    sexPatient: "M",
    codAna: "1050",
    matProfessional: "123",
    prescriptionDate: "2021-01-01",
    prescriptionDescription: "Classic exam",
    totalPrice: "1000",
  });
});

app.post("/register-order", (req, res = express.response) => {
  return res.status(200).json();
});

export default app;
