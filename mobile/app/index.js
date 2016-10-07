import React, { Component } from 'react'
import { Provider } from 'react-redux'
import { compose, createStore, applyMiddleware } from 'redux'
import thunk from 'redux-thunk'
import reducers from './reducers'
import App from './components/App'

let store = createStore(
  reducers,
  applyMiddleware(thunk)
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
