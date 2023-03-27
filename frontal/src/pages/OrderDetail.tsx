import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { Order } from '../interfaces';

export const OrderDetail = () => {
  const { idOrder } = useParams();
  const [order, setOrder] = useState<Order>();

  useEffect(() => {
    const getOrderById = async () => {
      try {
        const response = await fetch(`${process.env.REACT_APP_API_URL}/get-order/${idOrder}`);
        const data = await response.json();
        console.log('data: ', data);
        setOrder(data);
      } catch (error) {
        console.log('error: ', error);
      }
    };

    getOrderById();
  }, []);

  return (
    <div>
      <div>Order Detail</div>
      {order && (
        <div>
          <div>IdOrder: {order.idOrder}</div>
          <div>date: {order.date}</div>
          <div>dniPatient: {order.dniPatient}</div>
          <div>namePatient: {order.namePatient}</div>
          <div>sexPatient: {order.sexPatient}</div>
          <div>codAna: {order.codAna}</div>
          <div>matProfessional: {order.matProfessional}</div>
          <div>prescriptionDate: {order.prescriptionDate}</div>
          <div>prescriptionDescription: {order.prescriptionDescription}</div>
          <div>totalPrice: {order.totalPrice}</div>
        </div>
      )}
    </div>
  );
};
