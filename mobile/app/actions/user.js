const logIt = (anything) => dispatch => {
  console.log(anything);
}

const loginError = (error: String) => {
  console.log("LOGIN ERROR")
  return {
    type: 'USER_LOGIN_ERROR',
    error
  }
}

const loginSuccess = (user: Object) => {
  return {
    type: 'USER_LOGIN_SUCCESS',
    username: 'keilan',
    id: 0
  }
}

export const login = (username: string, password: string) => dispatch => {
  if (username == null || username.length == 0) {
    return dispatch(loginError("Enter your username"))
  }

  if (password == null || password.length == 0) {
    return dispatch(loginError("Enter your password"))
  }

  return fetch("http://localhost:8080/api/auth/me")
    .then(dispatch(logIt("Done loggin in")))
    .catch(dispatch(loginError("Failed to login!")))
}

export const signUp = (username: string, password: string, email: string): SignUpAction => dispatch => {
  return fetch("http://localhost:8080/api/users")
}

type UserAction = LoginAction
