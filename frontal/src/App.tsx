import { AppRouter } from './router/AppRouter';
import { SnackbarProvider } from 'notistack';

const App = () => {
  return (
    <div>
      <SnackbarProvider maxSnack={3}>
        <AppRouter />
      </SnackbarProvider>
    </div>
  );
};

export default App;
