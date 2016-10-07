// @flow

import React, { Component } from 'react'
import { Text, View, TextInput, TouchableHighlight } from 'react-native'
import { connect } from 'react-redux'
import { login, showSignUp } from '../actions'

type SignUpState = {
  username: string;
  email: string;
  password: string;
  passwordConfirm: string;
  dob: string;
  zip: number;
}

class SignUpForm  extends Component {
  state: SignUpState;
  onClickFinish: (state: SignUpState) => void;

  constructor(props: {username: ?string, state: SignUpState, onClickFinish: (state: SignUpState) => void}) {
    super(props);
    this.state = props.state;
    this.onClickFinish = props.onClickFinish;

    if (props.username != null) {
      this.state.username = props.username;
    }
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
          value = {this.state.email}
          onChangeText = {(text: string) => this.setState({email: text}) }
          placeholder = "email"
        />
        <TextInput
          style = {{flex: 1, height: 50}}
          value = {this.state.password}
          onChangeText = {(text: string) => this.setState({password: text}) }
          placeholder = "password"
          secureTextEntry = {true}
        />
        <TextInput
          style = {{flex: 1, height: 50}}
          value = {this.state.passwordConfirm}
          onChangeText = {(text: string) => this.setState({passwordConfirm: text}) }
          placeholder = "confirm password"
          secureTextEntry = {true}
        />
        <View style={{flex: 1, flexDirection: 'row', alignItems: 'center'}}>
          <TouchableHighlight
            style={{flex: 1, height: 50}}
            onPress= {() => this.onClickFinish(this.state)}
          >
            <Text>Finish</Text>
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
    onClickFinish: (state: SignUpState): void => {
      console.log("Finish", state);
    }
  }
}

SignUpForm = connect(mapStateToProps, mapDispatchToProps)(SignUpForm)

export default SignUpForm
