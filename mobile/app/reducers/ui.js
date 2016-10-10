// @flow

import { State, Action } from 'react-redux'
import { UI_SHOW_LOGIN, UI_LOGIN_ERROR, UI_SIGNUP_ERROR } from '../actions/ui'

const ui = (state: State = {}, action: Action): State => {
  switch(action.type) {
    case UI_LOGIN_ERROR:
      return {
        ...state,
        loginError: action.error
      }
    case UI_SIGNUP_ERROR:
      return {
        ...state,
        signUpError: action.error
      }
    default: return state
  }
}

export default ui
