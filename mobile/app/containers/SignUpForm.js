// @flow

import React, { Component } from 'react'
import { Text, View, TextInput, TouchableHighlight } from 'react-native'
import dismissKeyboard from 'dismissKeyboard'
import DatePicker from 'react-native-datepicker'
import { connect, State, Dispatch } from 'react-redux'
import { signUp } from '../actions/auth'
import Button from '../components/Button'
import HideKeyboard from '../components/HideKeyboard'
import styles, { TREATME_RED } from '../styles'

class SignUpForm  extends Component {
  state: State;
  signUpError: string;
  onClickNext: (state: State) => void;

  constructor(props: {username: ?string, signUpError: string, onClickNext: (state: State) => void}) {
    super(props);
    this.state = {};
    this.onClickNext = props.onClickNext;

    if (props.username != null) {
      this.state.username = props.username;
    }
  }

  render() {
    let nextDisabled = !(this.state.username && this.state.email && this.state.password && this.state.passwordConfirm && this.state.zip && this.state.dob)

    return (
      <HideKeyboard>
        <View style={{flex: 1, flexDirection: 'row', alignItems: 'center'}}>
          <View style={{flex: 1, flexDirection: 'column', alignItems: 'center', padding: 40}}>
            <TextInput
              style= { [styles.input, styles.inputText] }
              value = {this.state.username}
              onChangeText = {(text: string) => this.setState({username: text}) }
              placeholder = "username"
            />
            <TextInput
              style= { [styles.input, styles.inputText] }
              value = {this.state.email}
              keyboardType = 'email-address'
              onChangeText = {(text: string) => this.setState({email: text}) }
              placeholder = "email"
            />
            <TextInput
              style= { [styles.input, styles.inputText] }
              value = {this.state.password}
              onChangeText = {(text: string) => this.setState({password: text}) }
              placeholder = "password"
              secureTextEntry = {true}
            />
            <TextInput
              style= { [styles.input, styles.inputText] }
              value = {this.state.passwordConfirm}
              onChangeText = {(text: string) => this.setState({passwordConfirm: text}) }
              placeholder = "confirm password"
              secureTextEntry = {true}
            />
            <TextInput
              style = { [styles.input, styles.inputText] }
              value = {this.state.zip}
              keyboardType = 'numeric'
              onChangeText = {(text: string) => {
                this.setState({zip: text})

                if (text && text.length == 5) {
                  dismissKeyboard()
                }
              }}
              placeholder = "zip code"
            />
            <View style = {{flexDirection: 'row', alignItems: 'center'}}>
              <DatePicker
                style = {{
                  flex: 1,
                  height: 40,
                  marginBottom: 10,
                }}
                customStyles = {{
                  dateInput: {
                    borderWidth: 1,
                    borderColor: 'black',
                    borderRadius: 5,
                    backgroundColor: 'white',
                    padding: 5,
                    paddingLeft: 15,
                    alignItems: 'flex-start'
                  },
                  dateText: styles.inputText,
                  placeholderText: styles.placeholderText
                }}
                mode = "date"
                showIcon = {false}
                confirmBtnText = "Confirm"
                cancelBtnText = "Cancel"
                date = {this.state.dob}
                onDateChange = {(date: Date) => this.setState({dob: date}) }
                placeholder = "date of birth"
              />
            </View>
            <View style={{flexDirection: 'row', alignItems: 'flex-end', marginBottom: 10}}>
              <View style={{flex: 0.5}} />
              <Button
                text="Next"
                onPress={() => this.onClickNext(this.state)}
                style= {{flex: 0.5}}
                disabled={nextDisabled}
              />
            </View>
            <Text style={{minHeight: 40, color: TREATME_RED, textAlign: 'center'}}>{this.props.signUpError}</Text>
          </View>
        </View>
      </HideKeyboard>
    )
  }
}

const mapStateToProps = (state: State) => {
  return {
    signUpError: state.ui.signUpError
  }
}

const mapDispatchToProps = (dispatch: Dispatch) => {
  return {
    onClickNext: (state: State): void => {
      dispatch(signUp(state.username, state.email, state.password, state.passwordConfirm, state.zip, state.dob))
    }
  }
}

SignUpForm = connect(mapStateToProps, mapDispatchToProps)(SignUpForm)

export default SignUpForm
