// @flow

import { Dispatch, State } from 'react-redux'

const loginError = (error: string) => {
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

export const login = (username: string, password: string): any => (dispatch: Dispatch) => {
  if (username == null || username.length == 0) {
    return dispatch(loginError("Enter your username"))
  }

  if (password == null || password.length == 0) {
    return dispatch(loginError("Enter your password"))
  }

  return fetch("http://localhost:8080/api/auth/me")
    .then( () => {
      console.log("Logged in")
      dispatch(loginSuccess({}))
    })
    .catch( error => dispatch(loginError("Failed to login: " + error)))
}

const signUpError = (error: string) => {
  return {
    type: 'USER_SIGNUP_ERROR',
    error
  }
}

const signUpSuccess = (user: Object) => {
  return {
    type: 'USER_SIGNUP_SUCCESS',
    username: 'keilan',
    id: 0
  }
}

export const signUp = (username: string, email: string, password: string, passwordConfirm: string, zip: string, dob: Date) => (dispatch: Dispatch) => {

  if (!username || !email || !password || !passwordConfirm || !zip || !dob) {
    return dispatch(signUpError("Please fill out every field"))
  }

  if (password != passwordConfirm) {
    return dispatch(signUpError("Passwords must match"))
  }

  return fetch("http://localhost:8080/api/users")
    .then( () => {
      console.log("Signed up")
      dispatch(signUpSuccess({}))
    })
    .catch( error => {
      console.log(error)
      dispatch(signUpError("" + error))
    })
}
