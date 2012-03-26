// JadeDS SDK - Version 1 (2011-05-25)
// (C)opyright 2011 by Mediaguild UG
// This header is the interface to the official Jade:DS development kit.

#ifndef JADEDS_SDK_H
#define JADEDS_SDK_H

#include <map>
#include <string>
#include <vector>

#if defined(WIN32) && defined(JADEDLL_EXPORTS)
#define JADE_EXPORT __declspec(dllexport)
#elif defined(WIN32) && defined(JADEDLL_IMPORTS)
#define JADE_EXPORT __declspec(dllimport)
#else
#define JADE_EXPORT
#endif

namespace JadeSDK
{
	// Type definitions for convenience
	typedef void * Pointer;
	typedef unsigned char UInt8;
	typedef unsigned short UInt16;
	typedef unsigned long UInt32;
	typedef unsigned long long Time;
	typedef long Int32;

	// Class:       StreamFile
	// Parent:      none
	// Description: This is the most basic access to the files in the archives. All actions
	//              are executed directly through the client and the access is strictly
	//              sequential. It is recommended to use this type of file access only if
	//              the file is really big and shouldn't be held in memory completly.
	class JADE_EXPORT StreamFile
	{
	public:

		// Enum:        StreamFile::Status
		// Description: This enumeration defines 
		typedef enum
		{
			Ready = 0,	// File is ready for reading data
			EndOfFile,	// The index is at the end of the file, no more reading possible
			Closed,		// The file has been closed already
		} Status;

		virtual ~StreamFile();

		// Method:      dispose
		// Parameter:   none
		// Description: Frees the file object within its own memory context to prevent troubles
		//              with different memory allocators.
		virtual void dispose(void) = 0;

		// Method:      read
		// Parameter:   targetBuffer - Memory buffer to receive the data, must be at least
		//                             bytesToRead bytes.
		//              bytesToRead  - Bytes to be read into the buffer
		// Description: Reads an amount of bytes into the specified buffer
		virtual UInt32 read(Pointer targetBuffer,UInt32 bytesToRead) = 0;

		// Method:      tell
		// Parameter:   none
		// Description: Returns the current read position within the file.
		virtual UInt32 tell(void) = 0;

		// Method:      size
		// Parameter:   none
		// Description: Returns the size of the file.
		virtual UInt32 size(void) = 0;

		// Method:      close
		// Parameter:   none
		// Description: Closes the access to the file.
		virtual void close(void) = 0;

		// Method:      status
		// Parameter:   none
		// Description: Returns the status of the last operation.
		virtual Status status(void) = 0;
	};

	// Class:       SeekFile
	// Parent:      StreamFile
	// Description: This type of file access supports random file access to files in
	//              the archives, but these files have to be uncompressed and unencrypted.
	//              This type is aimed for streaming files, like videos or big level
	//              files, which need random access and can't be held in memory at once.
	class JADE_EXPORT SeekFile : public StreamFile
	{
	public:
		// Enum:        SeekFile::Origin
		// Description: 
		typedef enum
		{
			Begin = 0,	// Set file position relative to the beginning of the file position,
						// must be zero or above
			Current,	// Set file position relative to the current file position, can be a
						// positive as well as a negative value
			End			// Set file position relative to the end of the file, must be a
						// negative value
		} Origin;

		virtual ~SeekFile();

		// Method:      seek
		// Parameter:   position - The distance, which the file position shall be moved
		//              origin   - The origin to which the distance is added
		// Description: Repositions the file position relative to the given origin.
		virtual bool seek(Int32 position,Origin origin) = 0;
	};

	// Class:       MemoryFile
	// Parent:      SeekFile
	// Description: This type of access loads the file into memory first and provides a virtual
	//              file access on that block. This should be the general type of access, as it
	//              is the most performant.
	class JADE_EXPORT MemoryFile : public SeekFile
	{
	public:
		virtual ~MemoryFile();

		// Method:      data
		// Parameter:   none
		// Description: Returns a direct pointer to the file data, if the file access methods
		//              are not needed or wanted.
		virtual Pointer data(void) = 0;
	};

	// Class:       Directory
	// Parent:      none
	// Description: Stores the directory layout from a base directory. The container can store
	//              the data linear or hierachical.
	class JADE_EXPORT Directory
	{
	public:
		// Enum:        Directory::Type
		// Description: Defines the file types of a directory
		typedef enum
		{
			SubDirectory = 0,	// The file is a sub directory
			StreamFile,			// The file can be used with all types of file access
			SeekFile,			// The file can be used with the SeekFile class
		} Type;

		virtual ~Directory();

		static const UInt32 notFound = 0xFFFFFFFF;

		// Method:      dispose
		// Parameter:   none
		// Description: Frees the directory object within its own memory contect, avoiding problems
		//              with the memory allocator. Use this only on the root object!
		virtual void dispose(void) = 0;

		// Method:      entryCount
		// Parameter:   none
		// Description: Number of files within this container
		virtual UInt32 entryCount(void) = 0;
		
		// Method:      findEntry
		// Parameter:   name - Name of the file to be found
		// Description: Returns the index of a specified file or notFound, if not
		//              found
		virtual UInt32 findEntry(const std::string &name) = 0;
		
		// Method:      getSubDirectory
		// Parameter:   index -
		// Description: Returns a reference to the specified sub container
		virtual Directory &getSubDirectory(UInt32 index) = 0;
		
		// Method:      getEntry
		// Parameter:   index           - Index to the file
		//              namePtr         - Pointer to a string, which receives the name of the file
		//              sizePtr         - Pointer to receive the size of the file
		//              md5Ptr          - Pointer to a string, which receives the MD5 hash of the file
		//              typePtr         - Pointer to receive the type of the file
		//              creationPtr     - Pointer to receive the creation time in unix format
		//              modificationPtr - Pointer to receive the modification time in unix format
		// Description: Retrieves detailed information about the specified file entry
		virtual bool getEntry(UInt32 index,std::string *namePtr,UInt32 *sizePtr = 0L,std::string *md5Ptr = 0L,Type *typePtr = 0L,Time *creationPtr = 0L,Time *modificationPtr = 0L) = 0;
	};
	
	// Enum:        Connection::Status
	// Description: Possible status values for the connection.
	typedef enum
	{
		Unknown = 0,
		Success,				// Operation successful
		AlreadyConnected,		// The application is already connected
		UnsupportedVersion,		// The API version doesn't match the client
		VerificationFailed,		// Binary verfication of execution archive failed
		ClientLocked,			// Another instance of the product is already connected
		ClientNotRunning,		// The client is not running
		ClientTimedOut,			// The client didn't respond in time
		ApplicationFailed,		// The handshake with the application failed
		ApplicationUnknown,		// The specified product is unknown to the client
		ApplicationAborted,		// The launch of the application has been aborted
		FileNotFound,			// The file can't be found under the specified name
		DirectoryNotFound,		// The directory can't be found under the specified name
	} Status;

	// Enum:        StateModified
	// Description: 
	typedef enum
	{
		NoState = 0,
		Buddy = 1,			// Not implemented yet
		Client = 2,			// Not implemented yet
		Online = 4,			// The online status of the client has changed
		Avatar = 8,			// Not implemented yet
		Message = 16,		// At least one message is pending
		Billing = 32,		// Not implemented yet
		PlayTime = 64,		// The running time has changed
		StorageSlot = 128,	// At least one queried storage slot is pending
		StorageView = 256,	// At least one queried storage view is pending
		Achievement = 512,	// At least one achievement is pending
		SystemError = 1024,	// Not implemented yet
		AllImplemented = 980,
		AllStates = 2047,
	} StateModified;

	// Enum:        TickType
	// Description: The different types of time slots available
	typedef enum
	{
		GUI = 1,		// The application is in gui mode
		Paused = 2,		// The application is paused
		Playing = 4,	// The application is running
		Global = 7,		// The overall running time of the application
	} TickType;

	// Enum:        MessageType
	// Description: 
	typedef enum
	{
		MsgType_ShutDown,		// Sent, when the userserver is shut down
		MsgType_Maintenance,	// Sent, when the userserver is about to be shut down
		MsgType_Achievement,	// Sent, when someone on the users buddy list unlocks an
								// achievenebt
	} MessageType;

	// Enum:        BillingStatus
	// Description: 
	typedef enum
	{
		Demo,
		Unpaid,
		Pending,
		Paid,
		Expiring,
	} BillingStatus;

	// Enum:        LockStatus
	// Description: 
	typedef enum
	{
		Unlocked,
		Locked,
	} LockStatus;

	// Enum:        LogLevel
	// Description: The level up to which messages are reported
	typedef enum
	{
		Info,		// Log all messages
		Warning,	// Log only warnings and errors
		Error,		// Log only errors
	} LogLevel;

	// Enum:
	// Description: A list of possible error codes
	typedef enum
	{
		Error_None = 0,
		Error_InvalidSlot,
		Error_InvalidIndex,
		Error_InvalidView,
		Error_InvalidAchievement,
		Error_ServerFailure,
	} ErrorCode;

	// Class:       LogListener
	// Parent:      none
	// Description: A listener class to be used with the internal logging facility.
	class LogListener
	{
	public:
		virtual void log(LogLevel logLevel,std::string logMessage) = 0;
	};

	// Class:       StateSyncListener
	// Parent:      none
	// Description: This is the central callback listener. Use this as a parameter to updateStateSync
	//              and you'll receive all pending events without further code.
	class StateSyncListener
	{
	public:
		// Not implemented yet
		virtual void onError(ErrorCode errorCode,const std::string &errorText) = 0;

		// Not implemented yet
		virtual void onBuddy(const std::string &buddyName,const std::string &buddyAvatar) = 0;
			
		// Not implemented yet
		virtual void onProfileAvatar(const std::string &profileAvatar) = 0;

		// Not implemented yet
		virtual void onBuddyAvatar(const std::string &profile,const std::string &avatar) = 0;
			
		// Method:      onMessage
		// Parameter:   type    - Type of the message
		//              message - The text of the message
		//              icon    - An icon representation of the message as unparsed
		//                        PNG file
		// Description: This callback is triggered, if there is a pending message. See
		//              recvMessage for more details.
		virtual void onMessage(MessageType type,const std::string &message,const std::string &icon) = 0;
			
		// Not implemented yet
		virtual void onBilling(BillingStatus billingStatus,LockStatus lockStatus,int expiring) = 0;
			
		// Method:      onOnline
		// Parameter:   isConnected - True, if the client is connected to a user server,
		//                            otherwise false
		// Description: This callback is triggered, if the online status of the client
		//              has changed. See isOnline for more details.
		virtual void onOnline(bool isConnected) = 0;
			
		// Method:      onAchievement
		// Parameter:   achievement - Name of the achievement
		//              unlocked    - Unix time stamp when the achievement has been unlocked
		//                            or zero if not
		//              display     - A flag to determine, if the achievement needs to be
		//                            displayed
		// Description: This callback is triggered, if there is a pending achievement. See
		//              recvAchievement for more details.
		virtual void onAchievement(const std::string &achievement,Time unlocked,bool display) = 0;
			
		// Method:      onStorageSlot
		// Parameter:   slot  - Name of the pending storage slot
		//              index - Index of the pending data
		//              data  - Content of the storage slot at the specified index
		// Description: This callback is triggered, if there is a pending storage slot. See
		//              recvStorageSlot for more details.
		virtual void onStorageSlot(const std::string &slot,UInt32 index,const std::string &data) = 0;
			
		// Method:      onStorageView
		// Parameter:   view - Name of the read view
		//              data - Resulting table with data
		// Description: This callback is triggered, if there is a pending storage view. See
		//              recvStorageView for more details.
		virtual void onStorageView(const std::string &view,const std::string &data) = 0;
	};

	// Class:       SlotIndex
	// Parent:      None
	// Description: An utility class to store the name and the index of a
	//              storage slot.
	class SlotIndex
	{
	private:
		std::string name;
		UInt32 index;
	public:
		SlotIndex(const std::string &name,UInt32 index);

		// Method:      getName
		// Parameter:   none
		// Description: Returns the name of the slot.
		std::string getName(void) const;
			
		// Method:      getIndex
		// Parameter:   none
		// Description: Returns the selected index.
		UInt32 getIndex(void) const;
	};

	// Class:       Connection
	// Parent:      none
	// Description: The central connection class, which connects to the server and handles the
	//              exchange of data.
	class JADE_EXPORT Connection
	{
	public:
		virtual ~Connection();

		static const UInt32 waitNever = 0;				// For async operations, don't wait for pending
														// objects, but return immediatly, if the state
														// is clean.
		static const UInt32 waitInfinite = 0xFFFFFFFF;	// For async operations, never return before at
														// least one object is pending.

		// Method:      status
		// Parameter:   none
		// Description: Returns the status of the last operation.
		Status status(void);

		// Method:      openStreamFile
		// Parameter:   fileName   - Full path of the file within the mounted archives
		//              bufferSize - Size of the chunk buffer, this is the maximum
		//                           size of a read operation
		// Description: Opens a streamable file from the archives and returns an access object
		//              to it. A seek operation is not possible on these file objects.
		StreamFile *openStreamFile(const std::string &fileName,UInt32 bufferSize = 8192);

		// Method:      openSeekFile
		// Parameter:   fileName   - Full path of the file within the mounted archives
		//              bufferSize - Size of the chunk buffer, this is the maximum
		//                           size of a read operation
		// Description: Opens a streamable and seekable file from the archives, if possible.
		//              The file needs to be uncompressed and unencrypted for this.
		SeekFile *openSeekFile(const std::string &fileName,UInt32 bufferSize = 8192);

		// Method:      openMemoryFile
		// Parameter:   fileName - Full path of the file within the mounted archives
		// Description: Opens a file from the archives and loads it into memory at once. The
		//              basic file functions provide a seekable access to the file. This type
		//              of file access should be used in general, if the memory usage pays off
		//              the speed gain against direct file access.
		MemoryFile *openMemoryFile(const std::string &fileName);

		// Method:      readDirectory
		// Parameter:   base        - The base directory to read
		//              hierachical - Create a hierachical or a flat representation
		// Description: Reads the directory from the specified base path and stores it in one
		//              or more Directory-objects, depending on the hierachical flag.
		Directory *readDirectory(const std::string &base,bool hierachical = false);

		// Method:      updateStateSync
		// Parameter:   timeOut     - Time to wait, until the function returns. Provide
		//                            waitNever to let it return immediatly and waitInfitine
		//                            to return on a pending event only
		//              listenerPtr - An optional listener, which handles all pending events
		//                            and invokes a callback for each.
		// Description: This method checks, if there are any events pending and returns a
		//              mask with these events. For each pending event, a specific receive
		//              method needs to be called to clear the queues. For convenience, there
		//              is an optional listener, which already handles this and invokes
		//              callbacks for them. Afterwards, the method only returns timer events,
		//              as the other event types have been handled already.
		UInt32 updateStateSync(UInt32 timeOut,StateSyncListener *listenerPtr = 0L);

		// Method:      getRuntime
		// Parameter:   tickType - Type of the requested running time
		// Description: Returns the running time of a specific tick type, including
		//              the global running time.
		UInt32 getRuntime(TickType tickType);

		// Method:      getProfileName
		// Parameter:   none
		// Description: Returns the display name of the users profile, which launched the
		//              game. As the profile name is not changeable, this value is static
		//              during the runtime of an application.
		std::string getProfileName(void);

		// Not implemented yet
		std::string getProfileAvatar(void);

		// Not implemented yet
		bool queryAvatar(std::string profile);

		// Not implemented yet
		bool recvAvatar(std::string *profilePtr,std::string *avatarPtr);

		// Method:      recvMessage
		// Parameter:   typePtr    - A pointer to the type of the message
		//              messagePtr - A pointer to the message text
		//              iconPtr    - A pointer to a memory representation of an unparsed
		//                           PNG image
		// Description: Receives variouse types of status messages from the servers, e.g.
		//              achievements, server maintenance and others. Beside the localized
		//              and formated message - the clients language is used for this - an
		//              icon is provided with 32X32 pixels. This image is an unparsed PNG
		//              image and the application needs to convert it in a desired format.
		bool recvMessage(MessageType *typePtr,std::string *messagePtr,std::string *iconPtr);

		// Method:      queryStorageSlot
		// Parameter:   SlotIndex slot - Name and index of the slot to be requested
		// Description: This method queries a specific index of a named data slot from the
		//              backend server. The result is returned asynchonous with
		//              recvStorageSlot or the StateSyncListener.
		bool queryStorageSlot(const SlotIndex &slot);

		// Method:      queryStorageSlots
		// Parameter:	slots - A vector of SlotIndex with the names and indices of the
		//                      slots to be requested
		// Description: Similar to queryStorageSlot, this method queries multiple slots
		//              from the backend server. The result is returned asynchronous with
		//              recvStorageSlot or the StateSyncListener.
		bool queryStorageSlots(const std::vector<SlotIndex> &slots);

		// Method:      updateStorageSlot
		// Parameter:   slotName - Name of the slot to be updated
		//              slotData - New value for the slot
		//              index    - Index of the slot to be updated
		// Description: Send a new value to the server to update the named storage slot.
		//              Depending of the slot operator, the real new value is sent back,
		//              if this differs from the update value. This is the case for each
		//              operator type except set.
		bool updateStorageSlot(const std::string &slotName,const std::string &slotData,UInt32 index = 0);

		// Method:      recvStorageSlot
		// Parameter:   slotNamePtr - A Pointer to a string object, which receives the name
		//                            of the pending slot
		//              indexPtr    - A pointer to an unsigned integer, which receives the
		//                            index of the pending slot
		//              valuePtr    - A pointer to a string object, which receives the data
		//                            of the pending slot
		// Description: If there are pending storage slots to be read from, this method
		//              retrieves the name, index and value of the slot. The slot is then
		//              removed from the queue of pending slots. Alternatively, this data
		//              can be retrieved with the StateSyncListener.
		bool recvStorageSlot(std::string *slotNamePtr,UInt32 *indexPtr,std::string *valuePtr); 

		// Method:      queryStorageView
		// Parameter:   view   - Name of the requested view
		//              count  - Number of maximum entries
		//              offset - Offset to the first entry
		// Description: Queries for a storage view from the server. The returned data is
		//              formatted as a text block, where lines are seperated by a single
		//              linefeed and the columns are divided by a comma. The first row
		//              contains the field names.
		bool queryStorageView(const std::string &view,UInt32 count,UInt32 offset = 0);

		// Method:      recvStorageView
		// Parameter:   viewPtr -
		//              dataPtr -
		// Description: 
		bool recvStorageView(std::string *viewPtr,std::string *dataPtr);

		// Method:      recvAchievement
		// Parameter:   achievementPtr - Name of the achievement
		//              unlockedPtr    - Time of unlock in unix time format or zero if sill
		//                               not unlocked
		//              displayPtr     - Flag if the achievement should be visible or not
		//                               due to cascading achievements
		// Description: Reads pending achievements from a queue and populates the provided
		//              members. This event can be the result of a query, a recently unlocked
		//              achievement or one which changed its visibility due to changes in
		//              a cascading achievement row.
		bool recvAchievement(std::string *achievementPtr,Time *unlockedPtr,bool *displayPtr);

		// Method:      queryAchievement
		// Parameter:   achievement - Achievent to query
		// Description: Calls a query to the server for the specified achievement. If this
		//              achievement has been received before, the result is cached and used
		//              for the next invokation of receive.
		bool queryAchievement(const std::string &achievement);

		// Method:      queryAchievements
		// Parameter:   achievements -  Vector of achievements to query
		// Description: Calls a series of queries to the server for achievements. If these
		//              achievements have been received before, the result is cached and
		//              used for the next invokations of receive.
		bool queryAchievements(const std::vector<std::string> &achievements);

		// Method:      notifyTick
		// Parameter:   tickType     - Applications tick status
		//              continueTick - Set this to false to initiate a status change,
		//                             otherwise set this to true
		//              stepping     - The stepping is a convenience method to let the
		//                             method perform its action only every stepping
		//                             call. With this, you can call this method in each
		//                             rendering frame, but the IPC call is done only in
		//                             the requested stepping for real
		// Description: Sends a pulse signal to the client for a specific tick type. The
		//              client then measures the time between this and the last pulse of
		//              this type and informs the application back, if the timestamp has
		//              changed since then. Too, the client transfers the timestamp back
		//              to the server to track the running time persistantly. If you
		//              change the tick type, send a last pulse with the old type and
		//              continueTick set to false. The method returns true on success or
		//              if the call hasn't been performed at all due to the stepper
		//              mechanism.
		bool notifyTick(TickType tickType,bool continueTick,UInt32 stepping = 1);

		// Method:      isOnline
		// Parameter:   none
		// Description: Retrieves the online status of the client.
		bool isOnline(void);

		// Method:      close
		// Parameter:   none
		// Description: Closes the connection to the client.
		void close(void);

		// Method:      Connection::init
		// Parameter:   product - Name of the product to connect with
		// Description: Initializes the API and connects to the client for the specified
		//              product. From here, the connection can be retrieved with
		//              getConnection.
		static Status init(const std::string &product,UInt32 stateMask = AllImplemented);

		// Method:      Connection::getConnection
		// Parameter:   none
		// Description: Returns the pointer of the current connection.
		static Connection *getConnection(void);

		// Method:      Connection::statusToStr
		// Parameter:   status - Status value of the last operation
		// Description: Convencience tool to convert a status value into a human readable
		//              string.
		static std::string statusToStr(Status status);

		// Method:      registerLogListener
		// Parameter:   listener - Callback, which is used for each reported message
		//              level  - Level of message filtering
		// Description: Register a callback for internal logging events. This can be used for
		//              diagnostics in the case of errors and for tracing actions. The logging
		//              parameter is a filter to reduce the amount of messages.
		static void registerLogListener(LogListener *listenerPtr,LogLevel level);

		// Method:      unregisterLogListener
		// Parameter:   listener - Callback to be removed
		// Description: Removes a callback from the list.
		static void unregisterLogListener(LogListener *listenerPtr);
	};
}

#endif
