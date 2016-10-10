import React, { Component } from 'react'
import { AsyncStorage } from 'react-native'
import { Provider } from 'react-redux'
import { compose, createStore, applyMiddleware } from 'redux'
import thunk from 'redux-thunk'
import reducers from './reducers'
import App from './components/App'
import { persistStore, autoRehydrate } from 'redux-persist'
import { checkAuth } from './actions/auth'

let store = createStore(
  reducers,
  undefined,
  compose(
    applyMiddleware(thunk),
    autoRehydrate()
  )
)

const initialAuthCheck = () => {
  store.dispatch(checkAuth())
}

persistStore(
  store,
  {
    storage: AsyncStorage,
    whitelist: ["auth"]
  },
  initialAuthCheck
)

class Root extends Component {
  render() {
    return (
      <Provider store={store}>
        <App />
      </Provider>
    )
  }
}

export default Root;
