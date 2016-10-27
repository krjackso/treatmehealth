import { combineReducers } from 'redux'
import user from './user'
import auth from './auth'
import ui from './ui'
import api from './api'

const reducers = combineReducers({
  auth,
  user,
  ui,
  api
})

export default reducers
