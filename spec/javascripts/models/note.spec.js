describe("Note", function() {
  it("returns the author", function() {
    var user = {};
    var usersCollectionStub = sinon.stub();
    usersCollectionStub.withArgs(999).returns(user);
    var project = {users: {get: usersCollectionStub}};
    var collection = {story: {collection: {project: project}}};
    var note = new Note({user_id: 999});
    note.collection = collection;
    expect(note.user()).toEqual(user);
    expect(usersCollectionStub).toHaveBeenCalledWith(999);
  });
});
