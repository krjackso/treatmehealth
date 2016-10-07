import { Actions as routes } from 'react-native-router-flux';

export const showSignUp = (username: string) => dispatch => {
  routes.signup({username})
}
