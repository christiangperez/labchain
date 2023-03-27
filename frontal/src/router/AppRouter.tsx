import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { Navbar } from '../layout/navbar/Navbar';
import { Home } from '../pages/Home';
import { ListOrders } from '../pages/ListOrders';
import { OrderDetail } from '../pages/OrderDetail';
import { RegisterOrder } from '../pages/RegisterOrder';
export const AppRouter = () => {
  //   if (loadingPlanDetail) {
  //     return <Loader />;
  //   }

  return (
    <BrowserRouter>
      <Navbar />
      <Routes>
        <Route element={<Home />} path="/" />
        <Route element={<ListOrders />} path="/list-orders" />
        <Route element={<OrderDetail />} path="/order-detail/:idOrder" />
        <Route element={<RegisterOrder />} path="/register-order" />
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </BrowserRouter>
  );
};
