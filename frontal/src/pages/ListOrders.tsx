import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Order } from '../interfaces';

export const ListOrders = () => {
  const navigate = useNavigate();

  const [orders, setOrders] = useState<Order[]>([]);
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
          <div key={order.idOrder}>
            <div>Id Orden: {order.idOrder}</div>
            <div>Dni Patient: {order.dniPatient}</div>
            <div>Name Patient: {order.namePatient}</div>
            <div>Prescription: {order.prescriptionDescription}</div>
            <div>Total Price: {order.totalPrice}</div>
            <button onClick={handleClickViewDetail}>View Detail</button>
          </div>
        ))}
    </div>
  );
};
