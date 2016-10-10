import { combineReducers } from 'redux'
import user from './user'
import auth from './auth'
import ui from './ui'

const reducers = combineReducers({
  auth,
  user,
  ui
})

export default reducers
