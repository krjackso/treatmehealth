package controllers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/krjackso/treatmehealth/api/models"
	"github.com/krjackso/treatmehealth/api/util/authutil"
)

type AuthControllerImpl struct {
	UserModel models.UserModel
}

type AuthController interface {
	Me(http.ResponseWriter, http.Request)
	Index(http.ResponseWriter, http.Request)
	Login(http.ResponseWriter, http.Request)
	Refresh(http.ResponseWriter, http.Request)
}

type AuthResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token,omitempty"`
	ExpiresAt    int64  `json:"expires_at"`
}

func (self *AuthControllerImpl) Me(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	user, err := self.UserModel.GetById(ctx, 1)
	body, err := json.Marshal(user)
	if err != nil {
		fmt.Printf("Error: %s", err)
		return
	}
	jsonstring := string(body[:])
	fmt.Fprintf(w, jsonstring)
}

func (self *AuthControllerImpl) Index(w http.ResponseWriter, r *http.Request) {

}

func (self *AuthControllerImpl) Login(w http.ResponseWriter, r *http.Request) {
	auth := authutil.NewBasicAuthorization(r.Header)
	if auth == nil {
		w.WriteHeader(400)
		fmt.Fprintf(w, "Invalid Authorization header")
		return
	}

	ctx := r.Context()
	user, err := self.UserModel.GetByUsername(ctx, auth.Username)
	if err != nil {
		panic(err)
	}

	if user == nil {
		w.WriteHeader(401)
		return
	}

	if !user.Credential.Verify(auth.Password) {
		w.WriteHeader(401)
		return
	}

	refreshToken := models.NewRefreshToken()

	err = self.UserModel.AddRefreshToken(ctx, user.Id, refreshToken)
	if err != nil {
		println("Error adding refresh token: " + err.Error())
	}

	accessToken, expiresAt := models.NewAccessToken(user.Id)

	body, err := json.Marshal(&AuthResponse{
		RefreshToken: refreshToken.Token,
		AccessToken:  accessToken,
		ExpiresAt:    expiresAt,
	})
	if err != nil {
		panic(err)
	}
	fmt.Fprint(w, string(body[:]))
}

func (self *AuthControllerImpl) Refresh(w http.ResponseWriter, r *http.Request) {
	auth := authutil.NewBasicAuthorization(r.Header)
	if auth == nil {
		w.WriteHeader(400)
		fmt.Fprintf(w, "Invalid Authorization header")
		return
	}

	ctx := r.Context()
	user, err := self.UserModel.GetByUsername(ctx, auth.Username)
	if err != nil {
		panic(err)
	}

	if user == nil {
		w.WriteHeader(401)
		return
	}

	token, err := self.UserModel.GetRefreshToken(ctx, user.Id, auth.Password)
	if err != nil {
		panic(err)
	}

	if token == nil {
		w.WriteHeader(401)
		return
	}

	if token.ExpiresAt.Before(time.Now().UTC()) {
		w.WriteHeader(401)
		return
	}

	accessToken, expiresAt := models.NewAccessToken(user.Id)

	body, err := json.Marshal(&AuthResponse{
		AccessToken: accessToken,
		ExpiresAt:   expiresAt,
	})
	if err != nil {
		panic(err)
	}
	fmt.Fprint(w, string(body[:]))

}
