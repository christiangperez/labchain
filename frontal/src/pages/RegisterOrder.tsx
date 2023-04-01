import { enqueueSnackbar } from 'notistack';
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './RegisterOrder.css';

export const RegisterOrder = () => {
  const navigate = useNavigate();
  const [date, setDate] = useState('');
  const [dniPatient, setDniPatient] = useState('');
  const [namePatient, setNamePatient] = useState('');
  const [sexPatient, setSexPatient] = useState('');
  const [codAna, setCodAna] = useState('');
  const [matProfessional, setMatProfessional] = useState('');
  const [prescriptionDate, setPrescriptionDate] = useState('');
  const [prescriptionDescription, setPrescriptionDescription] = useState('');
  const [totalPrice, setTotalPrice] = useState('');

  const handleSubmit = async (e: any) => {
    e.preventDefault();
    if (
      date &&
      dniPatient &&
      namePatient &&
      sexPatient &&
      codAna &&
      matProfessional &&
      prescriptionDate &&
      prescriptionDescription &&
      totalPrice
    ) {
      try {
        await fetch(`${process.env.REACT_APP_API_URL}/register-order`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            date,
            dniPatient,
            namePatient,
            sexPatient,
            codAna,
            matProfessional,
            prescriptionDate,
            prescriptionDescription,
            totalPrice
          })
        });
        
        enqueueSnackbar("Order registered!", { variant: 'success' });
        navigate("/list-orders");
      } catch (error) {
        console.log('error: ', error);
      }
    }
  };

  return (
    <div className="register-container">
      <h2 className="register-title">Complete the fields with your order data</h2>
      <form className="register-form" onSubmit={handleSubmit}>
        <input className="register-input" type="text" placeholder="Date" value={date} onChange={(f) => setDate(f.target.value)} />
        <input
          className="register-input"
          type="text"
          placeholder="Dni Patient"
          value={dniPatient}
          onChange={(f) => setDniPatient(f.target.value)}
        />
        <input
          className="register-input"
          type="text"
          placeholder="Name Patient"
          value={namePatient}
          onChange={(f) => setNamePatient(f.target.value)}
        />
        <input
          className="register-input"
          type="text"
          placeholder="Sex Patient"
          value={sexPatient}
          onChange={(f) => setSexPatient(f.target.value)}
        />
        <input className="register-input" type="text" placeholder="Cod analysis" value={codAna} onChange={(f) => setCodAna(f.target.value)} />
        <input
          className="register-input"
          type="text"
          placeholder="Cod Professional"
          value={matProfessional}
          onChange={(f) => setMatProfessional(f.target.value)}
        />
        <input
          className="register-input"
          type="text"
          placeholder="Prescription date"
          value={prescriptionDate}
          onChange={(f) => setPrescriptionDate(f.target.value)}
        />
        <input
          className="register-input"
          type="text"
          placeholder="Prescription description"
          value={prescriptionDescription}
          onChange={(f) => setPrescriptionDescription(f.target.value)}
        />
        <input
          className="register-input"
          type="text"
          placeholder="Total price"
          value={totalPrice}
          onChange={(f) => setTotalPrice(f.target.value)}
        />
        <button className="register-submit">Submit</button>
      </form>
    </div>
  );
};
