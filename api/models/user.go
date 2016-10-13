package models

import (
	"cloud.google.com/go/datastore"
	"context"
	"time"

	"github.com/krjackso/treatmehealth/api/services"
)

type User struct {
	Id         int64 `datastore:"-"`
	Username   string
	Email      string
	Zip        string
	Dob        time.Time
	Credential Credential `json:"-" datastore:",noindex"`
}

type UserModelImpl struct {
	Datastore *services.Datastore
}

type UserModel interface {
	GetById(context.Context, int64) (*User, error)
	GetByUsername(context.Context, string) (*User, error)
	GetByEmail(context.Context, string) (*User, error)
	Create(context.Context, string, string, Credential, string, time.Time) (*User, error)
}

func (self *UserModelImpl) GetById(ctx context.Context, id int64) (*User, error) {
	ctx = self.Datastore.NewContext(ctx)
	key := datastore.NewKey(ctx, "User", "", id, nil)

	user := &User{Id: key.ID()}
	err := self.Datastore.Client.Get(ctx, key, user)

	if err == datastore.ErrNoSuchEntity {
		return nil, nil
	} else if err != nil {
		return nil, err
	}

	return user, nil
}

func (self *UserModelImpl) GetByUsername(ctx context.Context, username string) (*User, error) {
	ctx = self.Datastore.NewContext(ctx)
	query := datastore.NewQuery("User").Filter("Username =", username).Limit(1)

	results := self.Datastore.Client.Run(ctx, query)

	var user User
	key, err := results.Next(&user)

	if err != nil {
		if err == datastore.Done {
			return nil, nil
		} else {
			return nil, err
		}
	}

	user.Id = key.ID()

	return &user, nil
}

func (self *UserModelImpl) GetByEmail(ctx context.Context, email string) (*User, error) {
	ctx = self.Datastore.NewContext(ctx)
	query := datastore.NewQuery("User").Filter("Email =", email).Limit(1)

	results := self.Datastore.Client.Run(ctx, query)

	var user User
	key, err := results.Next(&user)

	if err != nil {
		if err == datastore.Done {
			return nil, nil
		} else {
			return nil, err
		}
	}

	user.Id = key.ID()

	return &user, nil
}

type CreateUserError string

func (e CreateUserError) Error() string {
	return string(e)
}

func (self *UserModelImpl) Create(ctx context.Context, username string, email string, credential Credential, zip string, dob time.Time) (*User, error) {
	ctx = self.Datastore.NewContext(ctx)

	// Create the user
	key := datastore.NewIncompleteKey(ctx, "User", nil)

	user := &User{
		Username:   username,
		Email:      email,
		Credential: credential,
		Zip:        zip,
		Dob:        dob,
	}

	key, err := self.Datastore.Client.Put(ctx, key, user)
	if err != nil {
		return nil, err
	}

	user.Id = key.ID()

	return user, nil
}
