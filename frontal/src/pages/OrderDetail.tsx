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
          <div>IdOrder: {order.Id}</div>
          <div>date: {order.Date}</div>
          <div>dniPatient: {order.DniPatient}</div>
          <div>namePatient: {order.NamePatient}</div>
          <div>sexPatient: {order.SexPatient}</div>
          <div>codAna: {order.CodAna}</div>
          <div>matProfessional: {order.MatProfessional}</div>
          <div>prescriptionDate: {order.PrescriptionDate}</div>
          <div>prescriptionDescription: {order.PrescriptionDescription}</div>
          <div>totalPrice: {order.TotalPrice}</div>
        </div>
      )}
    </div>
  );
};
