// @flow

import { State, Action } from 'react-redux'
import { AUTH_USER, AUTH_SUCCESS, AUTH_EXPIRED, AUTH_FAILED } from '../actions/auth'

const auth = (state: State = {loggedIn: false}, action: Action): State => {
  switch(action.type) {
    case AUTH_USER:
      return {
        ...state,
        username: action.username
      }
    case AUTH_SUCCESS:
      return {
        ...state,
        loggedIn: true,
        id: action.id,
        accessToken: action.accessToken,
        refreshToken: action.refreshToken
      }
    case AUTH_EXPIRED:
      return {
        loggedIn: false,
        username: state.username
      }
    case AUTH_FAILED:
      return {
        loggedIn: false
      }
    default: return state
  }
}

export default auth

export const getAuth = (state: State) => state.auth
