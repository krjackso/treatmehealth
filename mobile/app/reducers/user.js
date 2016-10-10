// @flow

import { State, Action } from 'react-redux'
import { USER_UPDATED } from '../actions/user'

const user = (state: State = {}, action: Action): State => {
  switch(action.type) {
    case USER_UPDATED:
      return action.user
    default: return state
  }
}

export default user
