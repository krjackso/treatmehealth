// @flow

import { Dispatch } from 'react-redux'
import { Actions as routes } from 'react-native-router-flux';

export const UI_SHOW_LOGIN = 'UI_SHOW_LOGIN'
export const UI_LOGIN_ERROR = 'UI_LOGIN_ERROR'
export const UI_SIGNUP_ERROR = 'UI_SIGNUP_ERROR'

export const showLogin = () => (dispatch: Dispatch) => {
  routes.login()
}

export const showSignUp = (username: string) => (dispatch: Dispatch) => {
  routes.signup({username})
}

export const showProfile = (username: string) => (dispatch: Dispatch) => {
  console.log("showProfile")
  routes.profile({username})
}

export const showLoginError = (error: string) => {
  return {
    type: UI_LOGIN_ERROR,
    error
  }
}

export const showSignUpError = (error: string) => {
  return {
    type: UI_SIGNUP_ERROR,
    error
  }
}
