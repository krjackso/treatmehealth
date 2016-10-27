// @flow

import { State, Action } from 'react-redux'
import { API_BOOTSTRAP } from '../actions'

const api = (state: State = {}, action: Action): State => {
  switch(action.type) {
    case API_BOOTSTRAP:
      return action.links
    default: return state
  }
}

export default api

export const getApi = (state: State) => state.api
