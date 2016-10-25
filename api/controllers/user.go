package controllers

import (
	"encoding/json"
	"errors"
	"github.com/asaskevich/govalidator"
	"github.com/krjackso/treatmehealth/api/models"
	"github.com/krjackso/treatmehealth/api/util"
	"github.com/krjackso/treatmehealth/api/util/authutil"
	"github.com/pressly/chi"
	"github.com/pressly/chi/render"
	"io/ioutil"
	"net/http"
	"strconv"
	"time"
)

type UserControllerImpl struct {
	UserModel models.UserModel
}

type UserController interface {
	Get(http.ResponseWriter, http.Request)
	Put(http.ResponseWriter, http.Request)
}

func (self *UserControllerImpl) Get(w http.ResponseWriter, r *http.Request) {
	userId, err := strconv.ParseInt(chi.URLParam(r, "id"), 10, 64)
	if err != nil {
		http.Error(w, "id must be a number", http.StatusBadRequest)
		return
	}

	ctx := r.Context()
	authUserId := authutil.UserIdFromContext(ctx)

	if authUserId != userId {
		http.Error(w, "", http.StatusForbidden)
		return
	}

	user, err := self.UserModel.GetById(ctx, userId)
	if err != nil {
		panic(err)
	}
	if user == nil {
		http.Error(w, "", http.StatusNotFound)
		return
	}

	render.JSON(w, r, user)
}

type PutUserData struct {
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
	Zip      string `json:"zip"`
	Dob      string `json:"dob"`
}

func validateUserData(data PutUserData) error {
	dob, dobErr := util.ParseDate(data.Dob)
	eighteenYearsAgo := time.Now().AddDate(-18, 0, 0)

	switch {
	case len([]rune(data.Username)) < 6:
		return errors.New("Username must be at least 6 characters")
	case !govalidator.IsEmail(data.Email):
		return errors.New("Invalid email address")
	case len([]rune(data.Password)) < 6:
		return errors.New("Password must be at least 6 characters")
	case len([]rune(data.Zip)) == 0:
		return errors.New("Zip code is required")
	case dobErr != nil:
		return errors.New("Invalid date of birth")
	case dob.After(eighteenYearsAgo):
		return errors.New("Must be at least 18 years old")
	default:
		return nil
	}
}

func (self *UserControllerImpl) Put(w http.ResponseWriter, r *http.Request) {
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "", http.StatusBadRequest)
		return
	}

	var data PutUserData
	err = json.Unmarshal(body, &data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	err = validateUserData(data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	dob, _ := util.ParseDate(data.Dob)
	ctx := r.Context()

	// See if there is already a user for this username/email
	user, err := self.UserModel.GetByUsername(ctx, data.Username)
	if err != nil {
		panic(err)
	}
	if user != nil {
		http.Error(w, "Username not available", http.StatusConflict)
		return
	}

	user, err = self.UserModel.GetByEmail(ctx, data.Email)
	if err != nil {
		panic(err)
	}
	if user != nil {
		http.Error(w, "Email not available", http.StatusConflict)
		return
	}

	credential := models.NewCredential(data.Password)

	user, err = self.UserModel.Create(ctx, data.Username, data.Email, credential, data.Zip, dob)
	if err != nil {
		panic(err)
	}

	refreshToken := models.NewRefreshToken()

	err = self.UserModel.AddRefreshToken(ctx, user.Id, refreshToken)
	if err != nil {
		println("Error adding refresh token: " + err.Error())
	}

	accessToken, expiresAt := models.NewAccessToken(user.Id)

	render.Status(r, http.StatusCreated)
	render.JSON(w, r, &AuthResponse{
		RefreshToken: refreshToken.Token,
		AccessToken:  accessToken,
		ExpiresAt:    expiresAt,
	})
}
