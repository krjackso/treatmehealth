import React, { Component } from 'react'
import { View, Text } from 'react-native'
import LoginForm from '../containers/LoginForm'
import SignUpForm from '../containers/SignUpForm'
import {Scene, Router} from 'react-native-router-flux'

const App = () => {
  return <Router>
     <Scene key="root">
       <Scene key="login" component={LoginForm} title="Login"/>
       <Scene key="signup" component={SignUpForm} title="Sign Up"/>
     </Scene>
   </Router>
}

export default App
