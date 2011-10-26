describe("Note", function() {

  describe("user", function() {

    beforeEach(function() {
      this.user = {};
      this.usersCollectionStub = sinon.stub();
      this.usersCollectionStub.withArgs(999).returns(this.user);
      this.project = {users: {get: this.usersCollectionStub}};
      this.note = new Note({user_id: 999});
      this.note.collection = {story: {collection: {project: this.project}}};
    });

    it("returns the author", function() {
      expect(this.note.user()).toEqual(this.user);
      expect(this.usersCollectionStub).toHaveBeenCalledWith(999);
    });

    it("returns the name of the user", function() {
      this.user.get = sinon.stub().withArgs('name').returns('User Name');
      expect(this.note.userName()).toEqual('User Name');
    });

    it("returns a placeholder when the user is null", function() {
      this.usersCollectionStub.withArgs(999).returns(null);
      expect(this.note.userName()).toEqual('Author unknown');
    });


  });
});
