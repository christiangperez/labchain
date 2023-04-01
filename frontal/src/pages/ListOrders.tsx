import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Orders } from '../interfaces';

export const ListOrders = () => {
  const navigate = useNavigate();

  const [orders, setOrders] = useState<Orders[]>([]);
  const handleClickViewDetail = () => {
    navigate('/order-detail/1');
  };

  useEffect(() => {
    const getAllOrders = async () => {
      try {
        const response = await fetch(`${process.env.REACT_APP_API_URL}/get-all`);
        const data = await response.json();
        setOrders(data);
      } catch (error) {
        console.log('error: ', error);
      }
    };

    getAllOrders();
  }, []);

  return (
    <div>
      <div>Orders</div>
      {orders &&
        orders.map((order) => (
          <div key={order.Key}>
            <div>Id Orden: {order.Key}</div>
            <div>Dni Patient: {order.Record.DniPatient}</div>
            <div>Name Patient: {order.Record.NamePatient}</div>
            <div>Prescription: {order.Record.PrescriptionDate}</div>
            <div>Total Price: {order.Record.TotalPrice}</div>
            <button onClick={handleClickViewDetail}>View Detail</button>
          </div>
        ))}
    </div>
  );
};
