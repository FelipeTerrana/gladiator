import os
import numpy as np
import cv2 as cv
from skimage.metrics import structural_similarity

FIRST = 1
SECOND = 2

BACKGROUND_COLOR = [np.uint8(85), np.uint8(75), np.uint8(69)]
SIMILARITY_THRESHOLD = 0.6



def rotate(image, angle):
    background = (int(BACKGROUND_COLOR[0]), int(BACKGROUND_COLOR[1]), int(BACKGROUND_COLOR[2]))
    image_center = tuple(np.array(image.shape[1::-1]) / 2)
    rot_mat = cv.getRotationMatrix2D(image_center, angle, 1.0)
    result = cv.warpAffine(image, rot_mat, image.shape[1::-1], flags=cv.INTER_LINEAR, borderValue=background)
    return result



def is_valid_pair(first_char, second_char):
    if not (first_char.is_set() and second_char.is_set()):
        return False

    if not (first_char.start_col <= first_char.end_col):
        return False

    if not (first_char.end_col < second_char.start_col):
        return False

    if not (second_char.start_col <= second_char.end_col):
        return False

    return True



def get_image_characters(path):
    image = cv.imread(path)

    first_char = CaptchaCharacter(image, FIRST)
    second_char = CaptchaCharacter(image, SECOND)

    if is_valid_pair(first_char, second_char):
        return (first_char, second_char)
    else:
        return (None, None)



def uncaptcha(path, print_similarity = False):
    (first_char, second_char) = get_image_characters(path)

    if first_char != None and second_char != None:
        first_char_match = first_char.matching_character(print_similarity)

        if first_char_match == None:
            return None

        second_char_match = second_char.matching_character(print_similarity)

        if second_char_match == None:
            return None

        return first_char_match + second_char_match
    else:
        return None



class CaptchaCharacter:
    def __process_as_first(self):
        self.start_row = self.rows - 1
        self.end_row = 0
        self.start_col = None
        self.end_col = None

        for column in range(0, self.cols):
            for row in range(0, self.rows):
                if not np.array_equal( self.image[row, column], BACKGROUND_COLOR ):
                    self.start_col = column
                    if row < self.start_row:
                        self.start_row = row
                    if self.end_row < row:
                        self.end_row = row

            if self.start_col != None:
                break

        if self.start_col == None:
            return

        for column in range(self.start_col + 1, self.cols):
            hasDifferentColor = False
            for row in range(0, self.rows):
                if not np.array_equal( self.image[row, column], BACKGROUND_COLOR ):
                    if row < self.start_row:
                        self.start_row = row
                    if self.end_row < row:
                        self.end_row = row
                    hasDifferentColor = True

            if not hasDifferentColor:
                self.end_col = column - 1
                break

        if self.end_col == None:
            self.end_col = self.cols - 1



    def __process_as_second(self):
        self.start_row = self.rows - 1
        self.end_row = 0
        self.start_col = None
        self.end_col = None

        for column in reversed( range(0, self.cols) ):
            for row in range(0, self.rows):
                if not np.array_equal( self.image[row, column], BACKGROUND_COLOR ):
                    self.end_col = column
                    if row < self.start_row:
                        self.start_row = row
                    if self.end_row < row:
                        self.end_row = row

            if self.end_col != None:
                break

        if self.end_col == None:
            return

        for column in reversed( range(0, self.end_col) ):
            hasDifferentColor = False
            for row in range(0, self.rows):
                if not np.array_equal( self.image[row, column], BACKGROUND_COLOR ):
                    hasDifferentColor = True
                    if row < self.start_row:
                        self.start_row = row
                    if self.end_row < row:
                        self.end_row = row

            if not hasDifferentColor:
                self.start_col = column + 1
                break

        if self.start_col == None:
            self.start_col = 0



    def __init__(self, image, position = FIRST):
        self.image = image.copy()
        (self.rows, self.cols, _) = self.image.shape

        if position == FIRST:
            self.__process_as_first()
        elif position == SECOND:
            self.__process_as_second()

        self.__normalize()



    def __crop(self):
        self.image = self.image[self.start_row : self.end_row + 1, self.start_col : self.end_col + 1]



    def __normalize(self):
        try:
            self.__crop()
            dimension = self.rows
            (height, width, _) = self.image.shape

            rows_before = int( np.floor( (dimension -  height) / 2.0 ) )
            rows_after = int( np.ceil( (dimension -  height) / 2.0 ) )

            cols_before = int( np.floor( (dimension -  width) / 2.0 ) )
            cols_after = int( np.ceil( (dimension -  width) / 2.0 ) )

            self.image = np.concatenate( (np.full((rows_before, width, 3), BACKGROUND_COLOR), self.image), axis=0 )
            self.image = np.concatenate( (self.image, np.full((rows_after, width, 3), BACKGROUND_COLOR)), axis=0 )

            self.image = np.concatenate( (np.full((dimension, cols_before, 3), BACKGROUND_COLOR), self.image), axis=1 )
            self.image = np.concatenate( (self.image, np.full((dimension, cols_after, 3), BACKGROUND_COLOR)), axis=1 )
        except:
            pass



    def get_similarity(self, alphabet_letter):
        angle_range = range(-45, 46, 15)
        highest_similarity = None

        for angle in angle_range:
            rotated_letter = CaptchaCharacter( rotate(alphabet_letter, angle) )
            similarity = structural_similarity(self.image, rotated_letter.image, multichannel=True, data_range=100.0)
            if highest_similarity == None or highest_similarity < similarity:
                highest_similarity = similarity

        return highest_similarity



    def matching_character(self, print_similarity = False):
        alphabet_folder = 'alphabet'
        alphabet = {filename[0]: cv.imread( os.path.join(alphabet_folder, filename) ) for filename in os.listdir('alphabet')}
        matching_character = None
        highest_similarity = None

        for character in alphabet:
            similarity = self.get_similarity( alphabet[character] )
            if highest_similarity == None or highest_similarity < similarity:
                matching_character = character
                highest_similarity = similarity

        if print_similarity:
            print(highest_similarity)

        if highest_similarity < SIMILARITY_THRESHOLD:
            return None
        else:
            return matching_character




    def is_set(self):
        return self.start_col != None and self.end_col != None and self.start_col <= self.end_col



    def __str__(self):
        return { 'start': self.start_col, 'end': self.end_col }.__str__()
