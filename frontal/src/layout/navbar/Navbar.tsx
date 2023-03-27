import { Link } from 'react-router-dom';

export const Navbar = () => {
  return (
    <div>
      <Link to="/">Home</Link>
      <Link to="/register-order">Register Order</Link>
      <Link to="/list-orders">List Orders</Link>
    </div>
  );
};
