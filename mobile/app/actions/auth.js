// @flow

import { Dispatch, State } from 'react-redux'
import { showLoginError, showSignUpError, showLogin } from './ui'
import { setUser } from './user'

export const AUTH_USER = 'AUTH_USER'
export const AUTH_SUCCESS = 'AUTH_SUCCESS'
export const AUTH_EXPIRED = 'AUTH_EXPIRED'
export const AUTH_FAILED = 'AUTH_FAILED'

const loginError = (error: string) => (dispatch: Dispatch) => {
  dispatch(showLoginError(error))
  dispatch({
    type: AUTH_FAILED
  })
}

const authSuccess = (accessToken: string, refreshToken: string, id: number) => {
  return {
    type: AUTH_SUCCESS,
    id: id,
    accessToken: accessToken,
    refreshToken: refreshToken
  }
}

const loginSuccess = (accessToken: string, refreshToken: string, user: Object) => (dispatch: Dispatch) => {
  dispatch(setUser(user))
  dispatch({
    type: AUTH_USER,
    username: user.username
  })
  dispatch(authSuccess(accessToken, refreshToken, user.id))
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
      dispatch(loginSuccess('acc', 'ref', {}))
    })
    .catch( error => dispatch(loginError("Failed to login: " + error)))
}

const signUpError = (error: string) => (dispatch: Dispatch) => {
  dispatch(showSignUpError(error))
  return dispatch({
    type: AUTH_FAILED
  })
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
      dispatch(loginSuccess('acc', 'ref', {}))
    })
    .catch( error => {
      console.log(error)
      //dispatch(signUpError("" + error))
      dispatch(loginSuccess('acc', 'ref', {username: 'krjackso'}))
    })
}

export const checkAuth = () => (dispatch: Dispatch, getState: Function) => {
  let auth = getState().auth

  if (!auth || !auth.loggedIn || !auth.accessToken || !auth.refreshToken) {
    return dispatch(showLogin())
  }

  return fetch("http://localhost:8080/api/auth/refresh")
    .then((auth) => {
      dispatch(authSuccess(auth.accessToken, auth.refreshToken, auth.id))
    })
    .catch((error) => {
      dispatch(showLogin())
    })

}
