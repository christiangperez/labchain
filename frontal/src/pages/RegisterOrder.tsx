import { useState } from 'react';

export const RegisterOrder = () => {
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
        console.log('order registered');
      } catch (error) {
        console.log('error: ', error);
      }
    }
  };

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <input type="text" placeholder="Date" value={date} onChange={(f) => setDate(f.target.value)} />
        <input
          type="text"
          placeholder="Dni Patient"
          value={dniPatient}
          onChange={(f) => setDniPatient(f.target.value)}
        />
        <input
          type="text"
          placeholder="Name Patient"
          value={namePatient}
          onChange={(f) => setNamePatient(f.target.value)}
        />
        <input
          type="text"
          placeholder="Sex Patient"
          value={sexPatient}
          onChange={(f) => setSexPatient(f.target.value)}
        />
        <input type="text" placeholder="Cod analisys" value={codAna} onChange={(f) => setCodAna(f.target.value)} />
        <input
          type="text"
          placeholder="Cod Professional"
          value={matProfessional}
          onChange={(f) => setMatProfessional(f.target.value)}
        />
        <input
          type="text"
          placeholder="Prescription date"
          value={prescriptionDate}
          onChange={(f) => setPrescriptionDate(f.target.value)}
        />
        <input
          type="text"
          placeholder="Prescription description"
          value={prescriptionDescription}
          onChange={(f) => setPrescriptionDescription(f.target.value)}
        />
        <input
          type="text"
          placeholder="Total price"
          value={totalPrice}
          onChange={(f) => setTotalPrice(f.target.value)}
        />
        <button>Submit</button>
      </form>
    </div>
  );
};
