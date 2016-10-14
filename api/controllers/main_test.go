package controllers_test

import (
	"context"
	"github.com/krjackso/treatmehealth/api/controllers"
	"github.com/krjackso/treatmehealth/api/models"
	"github.com/pressly/chi"
	"os"
	"testing"
	"time"
)

type UserModelMock struct{}

var testUserDob, _ = time.Parse("02/01/2006", "07/02/1992")
var testUser *models.User = &models.User{
	Id:         1,
	Username:   "testuser",
	Email:      "testuser@example.com",
	Credential: models.NewCredential("password"),
	Zip:        "92103",
	Dob:        testUserDob,
}

func (self *UserModelMock) GetById(ctx context.Context, id int64) (*models.User, error) {
	if id == testUser.Id {
		return testUser, nil
	} else {
		return nil, nil
	}
}

func (self *UserModelMock) GetByUsername(ctx context.Context, username string) (*models.User, error) {
	if username == testUser.Username {
		return testUser, nil
	} else {
		return nil, nil
	}
}

func (self *UserModelMock) GetByEmail(ctx context.Context, email string) (*models.User, error) {
	if email == testUser.Email {
		return testUser, nil
	} else {
		return nil, nil
	}
}

func (self *UserModelMock) Create(ctx context.Context, username string, email string, credential models.Credential, zip string, dob time.Time) (*models.User, error) {
	user := &models.User{
		Id:         2,
		Username:   username,
		Email:      email,
		Credential: credential,
		Zip:        zip,
		Dob:        dob,
	}
	return user, nil
}

var (
	router *chi.Mux
)

func TestMain(m *testing.M) {
	userModel := &UserModelMock{}
	router = controllers.Bootstrap(userModel)
	ret := m.Run()
	os.Exit(ret)
}
