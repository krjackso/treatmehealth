// @flow

import React, { Component } from 'react'
import { Text, View, TextInput, TouchableHighlight } from 'react-native'
import { connect } from 'react-redux'
import { login, signUp } from '../actions'
import {Actions} from 'react-native-router-flux';

type LoginState = {
  username: string;
  password: string;
}

class LoginForm  extends Component {
  state: LoginState;
  onClickSignIn: (state: LoginState) => void;
  onClickSignUp: (state: LoginState) => void;

  constructor(props: {state: LoginState, onClickSignIn: (state: LoginState) => void, onClickSignUp: (state: LoginState) => void}) {
    super(props)
    this.state = props.state;
    this.onClickSignIn = props.onClickSignIn;
    this.onClickSignUp = props.onClickSignUp;
  }

  render() {
    return (
      <View style={{flex: 1, flexDirection: 'column', alignItems: 'center', padding: 10}}>
        <TextInput
          style = {{flex: 1, height: 50}}
          value = {this.state.username}
          onChangeText = {(text: string) => this.setState({username: text}) }
          placeholder = "username"
        />
        <TextInput
          style = {{flex: 1, height: 50}}
          value = {this.state.password}
          onChangeText = {(text: string) => this.setState({password: text}) }
          placeholder = "password"
          secureTextEntry = {true}
        />
        <View style={{flex: 1, flexDirection: 'row', alignItems: 'center'}}>
          <TouchableHighlight
            style={{flex: 1, height: 50}}
            onPress= {() => this.onClickSignIn(this.state)}
          >
            <Text>Sign In</Text>
          </TouchableHighlight>
          <TouchableHighlight
            style={{flex: 1, height: 50}}
            onPress= {() => this.onClickSignUp(this.state)}
          >
            <Text>Sign Up</Text>
          </TouchableHighlight>
        </View>
      </View>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    state: {}
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onClickSignIn: (state: LoginState): void => {
      console.log("Sign In", state.username, state.password);
    },
    onClickSignUp: (state: LoginState): void => {
      console.log("Sign Up", state.username, state.password);
      Actions.signup({username: state.username});
    }
  }
}

LoginForm = connect(mapStateToProps, mapDispatchToProps)(LoginForm)

export default LoginForm
