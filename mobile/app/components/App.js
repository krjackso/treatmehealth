import React, { Component } from 'react'
import LoginForm from '../containers/LoginForm'
import SignUpForm from '../containers/SignUpForm'
import SplashScreen from '../components/SplashScreen'
import Profile from '../components/Profile'
import { Scene, Router, ActionConst } from 'react-native-router-flux'

const App = () => {
  return <Router>
     <Scene key="root">
       <Scene key="splash" component={SplashScreen} initial={true} hideNavBar={true}/>
       <Scene key="login" component={LoginForm} hideNavBar={true} type={ActionConst.RESET} title="Login"/>
       <Scene key="signup" component={SignUpForm} hideNavBar={false} title="Sign Up"/>
       <Scene key="profile" component={Profile} hideNavBar={true} title="Profile Setup"/>
     </Scene>
   </Router>
}

export default App
