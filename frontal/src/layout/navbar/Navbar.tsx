import { Link } from 'react-router-dom';
import './Navbar.css';

export const Navbar = () => {
  return (
    <div className="Navbar">
      <Link to="/">Home</Link>
      <Link to="/register-order">Register Order</Link>
      <Link to="/list-orders">List Orders</Link>
    </div>
  );
};
