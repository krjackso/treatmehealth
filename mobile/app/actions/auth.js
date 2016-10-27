// @flow

import { Dispatch } from 'react-redux'
import { showLoginError, showSignUpError, showLogin } from './ui'
import { setUser } from './user'
import TreatMe from './treatmeapi'
import { getAuth } from '../reducers/auth'
import { getApi } from '../reducers/api'

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

export const login = (username: string, password: string): any => (dispatch: Dispatch, getState: Function) => {
  if (username == null || username.length == 0) {
    return dispatch(loginError("Enter your username"))
  }

  if (password == null || password.length == 0) {
    return dispatch(loginError("Enter your password"))
  }

  let links = getState().api
  return TreatMe.login(links, username, password)
    .then( (data) => {
      console.log("Logged in", data)
      dispatch(loginSuccess(data.accessToken, data.refreshToken, data.user))
    })
    .catch( error => dispatch(loginError("Failed to login: " + error)))
}

const signUpError = (error: string) => (dispatch: Dispatch) => {
  dispatch(showSignUpError(error))
  return dispatch({
    type: AUTH_FAILED
  })
}

export const signUp = (username: string, email: string, password: string, passwordConfirm: string, zip: string, dob: Date) => (dispatch: Dispatch, getState: Function) => {

  if (!username || !email || !password || !passwordConfirm || !zip || !dob) {
    return dispatch(signUpError("Please fill out every field"))
  }

  if (password != passwordConfirm) {
    return dispatch(signUpError("Passwords must match"))
  }

  let links = getState().api
  return TreatMe.signUp(links, username, email, password, zip, dob)
    .then( (data) => {
      console.log("Signed up", data)
      dispatch(loginSuccess(data.accessToken, data.refreshToken, data.user))
    })
    .catch( error => {
      console.log("Sign up error", error)
      dispatch(signUpError("Failed to sign up: " + error))
    })
}

export const checkAuth = () => (dispatch: Dispatch, getState: Function) => {
  let auth = getAuth(getState())
  let api = getApi(getState())

  if (!auth || !auth.loggedIn || !auth.accessToken || !auth.refreshToken) {
    return dispatch(showLogin())
  }

  return TreatMe.refreshAuth(api, auth.username, auth.refreshToken)
    .then((auth) => {
      dispatch(authSuccess(auth.accessToken, auth.refreshToken, auth.id))
    })
    .catch((error) => {
      dispatch(showLogin())
    })

}
