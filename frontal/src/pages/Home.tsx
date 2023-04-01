import { useNavigate } from 'react-router-dom';
import './Home.css';

export const Home = () => {
  const navigate = useNavigate();

  const handleGetStarted = () => {
    navigate('/register-order');
  }

  return (
  <div className="home-container">
    <h1 className="home-title">LabChain</h1>
    <h2 className="home-subtitle">LaboratoryA</h2>
    <div className="home-getstarted">
      <h3>Platform to record all laboratory orders and automatically send them to the Government.</h3>
      <button className="home-getstarted-button" onClick={handleGetStarted}>Get started</button>
    </div>
    <h4 className="home-hyperledger">Las transacciones se realizan de forma segura y toda la red esta administrada con Hyperledger Fabric.</h4>
    <footer className="home-footer">Project developed by Christian Perez - BSM</footer>
  </div>
  );
};
