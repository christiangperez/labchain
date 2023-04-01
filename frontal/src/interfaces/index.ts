interface Record {
  Date: string;
  DniPatient: string;
  NamePatient: string;
  SexPatient: string;
  CodAna: string;
  MatProfessional: string;
  PrescriptionDate: string;
  PrescriptionDescription: string;
  TotalPrice: string;
}
export interface Orders {
  Key: string;
  Record: Record;
}

export interface Order {
  ID: string;
  Date: string;
  DniPatient: string;
  NamePatient: string;
  SexPatient: string;
  CodAna: string;
  MatProfessional: string;
  PrescriptionDate: string;
  PrescriptionDescription: string;
  TotalPrice: string;
}
