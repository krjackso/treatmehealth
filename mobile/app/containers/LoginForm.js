// @flow

import React, { Component } from 'react'
import { Text, View, TextInput, TouchableHighlight } from 'react-native'
import { connect, Dispatch, State } from 'react-redux'
import { login, showSignUp } from '../actions'
import Button from '../components/Button'
import styles, { TREATME_RED } from '../styles'

type LoginProps = {
  loginError: ?string;
  onClickSignIn: (state: State) => void;
  onClickSignUp: (state: State) => void;
}

class LoginForm  extends Component {
  props: LoginProps
  state: State

  constructor(props: LoginProps) {
    super(props)
    this.state = {}
  }

  render() {
    return (
      <View style={{flexDirection: 'row', alignItems: 'center', flex: 1}}>
        <View style={{flex: 1, flexDirection: 'column', alignItems: 'center', padding: 40}}>
          <TextInput
            style = {[styles.input, styles.inputText]}
            value = {this.state.username}
            onChangeText = {(text: string) => this.setState({username: text}) }
            placeholder = "username"
          />
          <TextInput
            style = {[styles.input, styles.inputText]}
            value = {this.state.password}
            onChangeText = {(text: string) => this.setState({password: text}) }
            placeholder = "password"
            secureTextEntry = {true}
          />
          <View style={{flexDirection: 'row', alignItems: 'center', marginBottom: 10}}>
            <Button
              disabled={!(this.state.username && this.state.password)}
              style={{marginRight: 5, flex: 1}}
              onPress = {() => this.props.onClickSignIn(this.state.username, this.state.password)}
              text = "Sign In"/>
            <Button
              style={{marginLeft: 5, flex: 1}}
              onPress = {() => this.props.onClickSignUp(this.state.username)}
              text = "Sign Up"/>
          </View>
          <Text style={{minHeight: 40, color: TREATME_RED, textAlign: 'center'}}>{this.props.loginError}</Text>
        </View>
      </View>
    )
  }
}

const mapStateToProps = (state: State = {}): Object => {
  return {
    loginError: state.user.loginError
  }
}

const mapDispatchToProps = (dispatch: Dispatch): Object => {
  return {
    onClickSignIn: (username: String, password: String): void => {
      dispatch(login(username, password, 8787));
    },
    onClickSignUp: (username: String): void => {
      dispatch(showSignUp(username));
    }
  }
}

LoginForm = connect(mapStateToProps, mapDispatchToProps)(LoginForm)

export default LoginForm
