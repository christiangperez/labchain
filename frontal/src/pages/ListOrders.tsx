import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Orders } from '../interfaces';
import './ListOrders.css';

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
    <div className="list-container">
      {orders &&
        orders.map((order) => (
          <div className="list-orders" key={order.Key}>
            <div>Id Orden: <b>{order.Key}</b></div>
            <div>Dni Patient: <b>{order.Record.DniPatient}</b></div>
            <div>Name Patient: <b>{order.Record.NamePatient}</b></div>
            <div>Prescription: <b>{order.Record.PrescriptionDate}</b></div>
            <div>Total Price: <b>{order.Record.TotalPrice}</b></div>
            <button className="list-viewdetail" onClick={handleClickViewDetail}>View Detail</button>
          </div>
        ))}
    </div>
  );
};
