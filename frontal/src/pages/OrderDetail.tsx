import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { Order } from '../interfaces';
import './OrderDetail.css';

export const OrderDetail = () => {
  const { idOrder } = useParams();
  const [order, setOrder] = useState<Order>();

  useEffect(() => {
    const getOrderById = async () => {
      try {
        const response = await fetch(`${process.env.REACT_APP_API_URL}/get-order/${idOrder}`);
        const data = await response.json();

        setOrder(data);
      } catch (error) {
        console.log('error: ', error);
      }
    };

    getOrderById();
  }, []);

  return (
    <div className="detail-container">
      {order && (
        <div className="detail-data">
          <h1 className="detail-orderid">Order {order.ID}</h1>
          <div>Date: <b>{order.Date}</b></div>
          <div>Dni Patient: <b>{order.DniPatient}</b></div>
          <div>Name Patient: <b>{order.NamePatient}</b></div>
          <div>Sex Patient: <b>{order.SexPatient}</b></div>
          <div>Cod Analysis: <b>{order.CodAna}</b></div>
          <div>Cod Professional: <b>{order.MatProfessional}</b></div>
          <div>Prescription Date: <b>{order.PrescriptionDate}</b></div>
          <div>Prescription Description: <b>{order.PrescriptionDescription}</b></div>
          <div>Total Price: <b>{order.TotalPrice}</b></div>
        </div>
      )}
    </div>
  );
};
